import assert from "node:assert/strict";
import test from "node:test";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";
import { listPublishedLuaSources } from "../scripts/menu-sources.mjs";

const root = fileURLToPath(new URL("../", import.meta.url));
const compiler = process.env.LUAU_COMPILE_BIN || "luau-compile";
const interpreter = process.env.LUAU_BIN || "luau";
const harness = await readFile(new URL("./client-harness.lua", import.meta.url), "utf8");
const sources = await listPublishedLuaSources();

function longString(value) {
  let fence = "=";
  while (value.includes(`]${fence}]`)) fence += "=";
  return `[${fence}[${value}]${fence}]`;
}

for (const level of [0, 1, 2]) {
  test(`all ${sources.length} published Lua files compile at O${level}`, () => {
    const result = spawnSync(compiler, ["--null", `-O${level}`, ...sources], {
      cwd: root, encoding: "utf8", timeout: 20000, maxBuffer: 2 * 1024 * 1024,
    });
    assert.equal(result.status, 0, result.error?.message || result.stderr || result.stdout);
  });
}

async function fixture(name, options, checks, clientChecks = "") {
  const directory = await mkdtemp(join(tmpdir(), "cafezl-client-test-"));
  try {
    // Appended checks share the chunk's locals without adding production test hooks.
    const source = `${await readFile(join(root, name), "utf8")}\n${clientChecks}\n`;
    const fields = Object.entries({ name, ...options }).map(([key, value]) => (
      `${key}=${typeof value === "string" ? longString(value) : String(value)}`
    )).join(",");
    const path = join(directory, "bootstrap.lua");
    await writeFile(path, `${harness}\nlocal result = runFixture(${longString(source)}, {${fields}})\n${checks}\n`);
    const result = spawnSync(interpreter, [path], {
      cwd: root, encoding: "utf8", timeout: 20000, maxBuffer: 2 * 1024 * 1024,
    });
    assert.equal(result.status, 0, result.error?.message || result.stderr || result.stdout);
  } finally {
    await rm(directory, { recursive: true, force: true });
  }
}

for (const [name, window] of [
  ["cafezitos/Cafezitos.lua", "CafezitosV2UI"],
  ["nothrilo/v1/Nothrilo.lua", "NothriloClassicUI"],
  ["nothrilo/v1/Nothrilo-classico-funcoes-corrigidas.lua", "NothriloClassicUI"],
]) {
  const visible = `
    assert(#result.failures == 0, table.concat(result.failures, "\\n"))
    assert(result.finished, "main bootstrap did not finish")
    local gui = result.core:FindFirstChild("${window}") or result.playerGui:FindFirstChild("${window}")
    assert(gui and gui.Enabled, "main window did not become visible")
    assert(#gui:GetDescendants() > 100, "menu lost its content")
    assert(gui:FindFirstChild("ComandosTabButton", true), "commands tab was lost")
  `;
  test(`${name}: builds a visible menu in the bootstrap model`, () => fixture(name, {}, visible));
  test(`${name}: waits for the player/GUI and falls back from an unusable gethui/CoreGui`, () => (
    fixture(name, { playerDelay: 0.2, guiDelay: 0.4, blockCore: true, badHui: true }, `${visible}
      assert(gui.Parent == result.playerGui, "expected PlayerGui fallback")
    `)
  ));
}

test("Nothrilo keeps the key gate closed when verification is unavailable", () => fixture(
  "nothrilo/v1/Nothrilo.lua", { networkFailure: true, maxTime: 1 }, `
    assert(#result.failures == 0, table.concat(result.failures, "\\n"))
    assert(not result.finished, "the menu must not skip failed verification")
    assert(result.core:FindFirstChild("NothriloKeyGate"), "the key UI disappeared")
    assert(not result.core:FindFirstChild("NothriloClassicUI"), "unverified menu was created")
  `,
));

test("Nothrilo discovers an inherited request function when client HttpService is unavailable", () => fixture(
  "nothrilo/v1/Nothrilo.lua", { inheritedRequest: true }, `
    assert(#result.failures == 0, table.concat(result.failures, "\\n"))
    assert(result.finished, "inherited request function was ignored")
    local gui = result.core:FindFirstChild("NothriloClassicUI")
    assert(gui and gui.Enabled, "verified menu did not open")
  `,
));

test("Nothrilo Classic requires a key and offers all three configured providers", () => fixture(
  "nothrilo/v1/Nothrilo-classico-funcoes-corrigidas.lua", { authorize: false, maxTime: 1 }, `
    assert(#result.failures == 0, table.concat(result.failures, "\\n"))
    assert(not result.finished, "Classic bypassed the key gate")
    local gate = result.core:FindFirstChild("NothriloKeyGate")
    assert(gate and not result.core:FindFirstChild("NothriloClassicUI"))
    for _, provider in ipairs({ "linkvertise", "workink", "lootlabs" }) do
      assert(gate:FindFirstChild(provider, true), provider .. " button missing")
    end
  `,
));

for (const option of ["closeGate", "replaceSuite"]) {
  test(`Nothrilo cancels its bootstrap cleanly after ${option}`, () => fixture(
    "nothrilo/v1/Nothrilo.lua", { authorize: false, [option]: true, maxTime: 1 }, `
      assert(#result.failures == 0, table.concat(result.failures, "\\n"))
      assert(result.finished, "cancelled gate kept waiting")
      assert(not result.core:FindFirstChild("NothriloKeyGate"), "key gate leaked")
      assert(not result.core:FindFirstChild("NothriloRuntime"), "runtime leaked")
      assert(not result.core:FindFirstChild("NothriloClassicUI"), "cancelled menu opened")
    `,
  ));
}

for (const name of ["cafezitos/Cafezitos.lua", "nothrilo/v1/Nothrilo.lua"]) {
  test(`${name}: reports a missing local player after a bounded wait`, () => fixture(name, { noPlayer: true }, `
    assert(result.finished, "missing-player wait did not end")
    assert(#result.failures == 1, "expected one descriptive client-context error")
    assert(result.failures[1]:find("jogador local", 1, true), result.failures[1])
    assert(result.elapsed >= 10 and result.elapsed < 10.2, "unexpected wait budget")
  `));
}

test("diagnostic loader shows a closable error instead of failing silently", () => fixture(
  "cafezitos/Cafezitos-teste.lua", {}, `
    assert(#result.failures == 0, table.concat(result.failures, "\\n"))
    assert(result.finished)
    local gui = result.core:FindFirstChild("CafezitosDiagnostic")
    assert(gui and gui.Enabled, "missing diagnostic UI")
    assert(#result.warnings == 1, "missing console diagnostic")
  `,
));

const cleanClientRun = `
  assert(#result.failures == 0, table.concat(result.failures, "\\n"))
  assert(result.finished, "client regression scenario did not complete")
`;

for (const scenario of [
  { name: "seated vehicle", seated: true, inputEnabled: true, platformStand: false },
  { name: "killer flight without a seat", seated: false, inputEnabled: false, platformStand: false },
  { name: "manual flight on foot", seated: false, inputEnabled: true, platformStand: true },
]) {
  test(`Nothrilo ${scenario.name} preserves humanoid flight state`, () => fixture(
    "nothrilo/v1/Nothrilo.lua", {}, cleanClientRun, `
      do
        local humanoid = getHumanoid()
        humanoid.AutoRotate = false
        humanoid.PlatformStand = false
        humanoid.MoveDirection = Vector3.zero
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        UserInputService.TouchEnabled = false
        if ${scenario.seated} then
          local seat = Instance.new("VehicleSeat", workspace)
          seat.Occupant = humanoid
          humanoid.SeatPart = seat
        end
        assert(startVehicleFly(${scenario.inputEnabled}), "flight did not start")
        assert(humanoid.PlatformStand == ${scenario.platformStand}, "incorrect PlatformStand during flight")
        stopFly()
        assert(humanoid.PlatformStand == false, "flight changed the original PlatformStand")
        assert(humanoid.AutoRotate == false, "flight changed a previously false AutoRotate")
        assert(humanoid:GetStateEnabled(Enum.HumanoidStateType.Freefall) == false, "Freefall state was lost")
        assert(humanoid:GetStateEnabled(Enum.HumanoidStateType.FallingDown) == true, "FallingDown state was lost")
        assert(not getRoot():FindFirstChild("CafezlVehicleFlyVelocity"), "flight mover leaked")
      end
    `,
  ));
}

test("Nothrilo accepts its current seat and rejects another occupant", () => fixture(
  "nothrilo/v1/Nothrilo.lua", {}, cleanClientRun, `
    do
      local humanoid = getHumanoid()
      local seat = Instance.new("VehicleSeat", workspace)
      seat.Occupant = humanoid
      humanoid.SeatPart = seat
      assert(sitOnVehicleSeat(seat), "already seated local player was rejected")
      humanoid.SeatPart = nil
      seat.Occupant = Instance.new("Humanoid", workspace)
      assert(not sitOnVehicleSeat(seat), "another player's seat was accepted")
    end
  `,
));

test("Nothrilo uses Humanoid.Sit after three unsuccessful seat requests", () => fixture(
  "nothrilo/v1/Nothrilo.lua", {}, cleanClientRun, `
    do
      local humanoid = getHumanoid()
      local seat = Instance.new("VehicleSeat", workspace)
      seat.CFrame = CFrame.new()
      humanoid.Sit = false
      local sitRequests = 0
      seat.Sit = function() sitRequests += 1 end
      task.spawn(function()
        local deadline = os.clock() + 2
        repeat task.wait(0.02) until humanoid.Sit or os.clock() >= deadline
        if humanoid.Sit then
          seat.Occupant = humanoid
          humanoid.SeatPart = seat
        end
      end)
      assert(sitOnVehicleSeat(seat), "fallback did not seat the player")
      assert(sitRequests == 3, "fallback skipped the three direct seating attempts")
      assert(humanoid.SeatPart == seat, "fallback reported success without the expected seat")
    end
  `,
));

test("Nothrilo ESP restores native nameplate settings and keeps the humanoid", () => fixture(
  "nothrilo/v1/Nothrilo.lua", {}, cleanClientRun, `
    do
      local player = Instance.new("Player", game:GetService("Players"))
      player.Name, player.DisplayName = "ESPFixture", "ESP Fixture"
      local character = Instance.new("Model", workspace)
      player.Character = character
      local root = Instance.new("Part", character)
      root.Name, root.Position = "HumanoidRootPart", Vector3.zero
      local humanoid = Instance.new("Humanoid", character)
      humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
      humanoid.NameOcclusion = Enum.NameOcclusion.OccludeAll
      humanoid.NameDisplayDistance = 87
      humanoid.HealthDisplayDistance = 42
      espEnabled = true
      addESP(player, character)
      assert(root:FindFirstChild("NothriloESPName"), "ESP nameplate was not created")
      assert(humanoid.DisplayDistanceType == Enum.HumanoidDisplayDistanceType.None, "native nameplate was not hidden")
      removeESP(player)
      assert(humanoid.Parent == character, "ESP cleanup destroyed the target humanoid")
      assert(humanoid.DisplayDistanceType == Enum.HumanoidDisplayDistanceType.Viewer, "display type was not restored")
      assert(humanoid.NameOcclusion == Enum.NameOcclusion.OccludeAll, "occlusion was not restored")
      assert(humanoid.NameDisplayDistance == 87 and humanoid.HealthDisplayDistance == 42, "display distances were not restored")
      assert(not root:FindFirstChild("NothriloESPName") and not character:FindFirstChild("NothriloESP"), "ESP objects leaked")
    end
  `,
));

test("Nothrilo stabilizer retires a force whose attachment was removed", () => fixture(
  "nothrilo/v1/Nothrilo.lua", {}, cleanClientRun, `
    do
      local cart = Instance.new("Model", workspace)
      local wheel = Instance.new("Part", cart)
      wheel.Name, wheel.Anchored = "Wheel", false
      wheel.Position, wheel.AssemblyLinearVelocity, wheel.AssemblyMass = Vector3.zero, Vector3.zero, 100
      cart.PrimaryPart = wheel
      stabilizer.enabled = true
      applyStabilizer(cart)
      local force = wheel:FindFirstChild("CafezlStabilizerForce")
      assert(force and force.Attachment0, "stabilizer force was not created")
      force.Attachment0:Destroy()
      RunService.Heartbeat:Fire()
      assert(not force.Parent, "force without a live attachment was left active")
      cleanupStabilizer()
    end
  `,
));
