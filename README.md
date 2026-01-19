<div align="center">

<img width="512" height="512" alt="logo" src="https://github.com/user-attachments/assets/45cebd1e-bc88-4e9b-93f2-df09e12591c4" />

<a href="https://discord.gg/pfhacX3ZPY">
  <div>
    

  </div>
  <b>
    Nocturnal, a Drawing based, undetectable UI Library for Roblox
    
  </b>
  <div>
    <sup>Read <u>further</u> to integrate</sup>
  </div>
</a>

<hr />

# Nocturnal

[![Github All Releases](https://img.shields.io/github/downloads/Storm99999/Nocturnal-Remastered/total.svg)]()
__Nocturnal__ — an integrative, performative and beautiful Library

Assets, Physics & Lighting all in one __Engine__ <br />
Nocturnal is written in Lua**U**, and is compatible only with __Drawing__ supported executors.

</div>

## Getting started
* Import the Library, locally, preferably.
```luau
local Library, ThreadList, CreateThread, MultiThreadList;
ThreadList = { };

function Download(FileName: string, User: string, Repository: string, File: string): { }
	if isfile(FileName) then return end;

	local Url: string = string.format("https://github.com/%s/%s/blob/main/%s?raw=true", User, Repository, File);
	local OK, Statement = pcall(function()
		local Data = game:HttpGetAsync(Url);

		pcall(writefile, FileName, Data);
	end)

	if OK then
        return { true, OK, Statement };
    else
        warn("[nocturnal @ downloader]", OK, Statement);
        return { false, OK, Statement };
    end;
end;

--// fetch
do
	assert(writefile, "[nocturnal @ fetch] Unsupported executor. | ", os.clock());
	assert(Drawing, "[nocturnal @ fetch] Unsupported executor. | ", os.clock());

	pcall(Download, "Library.lua", "Storm99999", "Nocturnal-Remastered", "Source.lua");
end;

pcall(function()
  Library = loadfile("Library.lua")();

  CreateThread, MultiThreadList = function(Func: (...any) -> (), ...: any): thread
        local Thread: thread = Library.Utility:CreateThread(Func, ...)
        Insert(ThreadList, Thread)

        return Thread;
    end, function(JobList: { any }, ...: any): { thread }
        local Threads: { thread } = {}

        local Count: number = #JobList
        if Count == 0 then return Threads end

        for i = 1, Count do
            local Item = JobList[i]

            if type(Item) == "table" then
                local Fn: (() -> ())? = Item[1]
                local Args: { any }? = Item[2]
                if type(Fn) == "function" then
                    local Thread: thread
                    if Args and type(Args) == "table" then
                        Thread = Library.Utility:CreateThread(Fn, Unpack(Args));
                    else
                        Thread = Library.Utility:CreateThread(Fn);
                    end;

                    table.insert(Threads, Thread);
                    table.insert(ThreadList, Thread);
                end;
            elseif type(Item) == "function" then
                local Thread: thread = Library.Utility:CreateThread(Item, ...);
                table.insert(Threads, Thread);
                table.insert(ThreadList, Thread);
            end;
        end;

        return Threads;
    end;
end)
```

## Issues
Got issues? [Our discord](https://discord.gg/6KeAYQ9bD8) is there to help! Join and ask around.
