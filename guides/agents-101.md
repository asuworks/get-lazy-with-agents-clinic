## agents 101: what agents are, what can they do and how we can control them
An **Agent** is a computer program with **initial parameters**:

```sh
1. Instructions # the "soul" of the agent - a text that is passed to the LLM as system prompt that explains how the agent should operate
2. Tools # a set of computer programs that allow the agent to "do things" like search your files, call an API, etc.
```

Generally any computer program can be a **tool**:

- File system tools: `grep`, `tree`, ...
- CLI tools: `gh`, `uv`, `python`, `npm`...
- `AskUserQuestion` - is an internal claude-code specific tool that an agent can use to give you a multiple choice question.
- browser
- MCP tools
- ...

Once the agent is given a **task** ("Hi, what can you do?"), it starts


**The Agent Loop**
```
while "task not done" use an LLM to decide whether to answer directly (from the training set) or to call one or multiple tools that could help solve the task.
```

The **message history** is sent to the LLM for "understanding" and decision on what to do next: call another tool or end the loop (with a response to the user):
```
- user messages
- tool results
- LLM responses
```

While the agent executes the loop, multiple internal **events** can occur:
```
- user submitts a message
- a tool is used
- a tool failed
- a sub-agent was spawned
- a file was changed
- ...
```
Most agents allow to intercept these events with hooks:
- `UserPromptSubmit`
- `preToolUse`
- `postToolUse`
- ... [full list of claude-code hooks](https://code.claude.com/docs/en/hooks)

For example you can enforce that agent never calls `rm -rf /`.

---
### **Instructions**, **tools**, **hooks** are means to control the behavior of the agent:
- **Instructions** tell how to do things
- **Tools** allow the agents to do things
- **Hooks** sit "on top" of the agentic loop and enforce deterministic behavior

This doesn't mean that you can guard your agent with hooks alone.
Remember, your agent has access to the terminal and can get very creative in trying to harm your system in many not obvious ways. This is why you should be careful when running your agent with `--dangerously-skip-all-permissions`.

---

### Extending agent capabilities with skills

Skills are custom instructions that your agent is able to invoke on demand:

For example, save the following to `~/.claude/skills/commit.md`:

````markdown
---
name: commit
description: Use when the user wants to commit staged git changes with a Conventional Commit message. Triggers on "commit", "commit my changes", "write a commit message".
---

# Commit skill

When invoked:

1. Run `git diff --cached` to read the staged changes.
2. Compose a Conventional Commit message:
   - **type** — `feat | fix | docs | refactor | test | chore`
   - **scope** *(optional)* — in parentheses
   - **subject** — imperative, under 72 chars, no trailing period
3. Show the user the proposed message.
4. On approval, run `git commit -m "<message>"`.
````

Invoke it:

```sh
"/commit"
"commit my changes for me"
```

The `description` field is what the agent matches against your prompt to decide when to invoke this skill — so make it specific. The body of the skill is plain markdown instructions: what to do, in what order.

Skills usually live in your user folder `~/.claude/skills` or in your project folder (`./claude/skills`)

The skills ecosystem seems to have converged on [this](https://agentskills.io/specification) skill specification and [this](https://www.skills.sh/) agent-agnostic way of skill distribution.