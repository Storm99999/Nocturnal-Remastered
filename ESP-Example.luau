local Esp = loadfile("esp.lua")()


Esp.teamSettings.enemy.enabled = true;
Esp.teamSettings.enemy.box = true;
Esp.teamSettings.enemy.cornerEsp = false;
Esp.teamSettings.enemy.chams = true
Esp.teamSettings.enemy.chamsStyle = "Drawing"

Esp.teamSettings.enemy.boxColor[1] = Color3.fromRGB(255, 255, 255);
--Esp.teamSettings.enemy.boxFill = true;
Esp.teamSettings.enemy.boxFillColor[1] = Color3.fromRGB(255, 255, 255);
Esp.teamSettings.enemy.skeleton = false;
Esp.Load();
