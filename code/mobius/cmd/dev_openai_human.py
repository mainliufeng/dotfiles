import sys
import json

from langchain.agents import AgentExecutor
from mobius.cases.dev import tools, llm

from langchain import hub
from langchain.agents import AgentExecutor
from langchain.agents.format_scratchpad.tools import (
    format_to_tool_messages,
)
from langchain.agents.output_parsers.tools import ToolsAgentOutputParser
from langchain_core.messages import AIMessage
from langchain_core.runnables import Runnable, RunnablePassthrough

# prompt
prompt = hub.pull("hwchase17/openai-tools-agent")
prompt.pretty_print()

def human_approval(msg: AIMessage) -> Runnable:
    if not msg.tool_calls:
        return msg

    tool_strs = "\n\n".join(
        json.dumps(tool_call, indent=2) for tool_call in msg.tool_calls
    ).encode("utf-8")
    input_msg = (
        f"是否授权执行下面工具\n\n{tool_strs}\n\n"
        "任何非'Y'/'Yes' (大小写不敏感) 都会被视为拒绝"
    )
    resp = input(input_msg)
    if resp.lower() not in ("yes", "y"):
        raise ValueError(f"拒绝执行工具:\n\n{tool_strs}")
    return msg

# agent
llm_with_tools = llm.bind_tools(tools)
agent = (
    RunnablePassthrough.assign(
        agent_scratchpad=lambda x: format_to_tool_messages(x["intermediate_steps"])
    )
    | prompt
    | llm_with_tools
    | human_approval
    | ToolsAgentOutputParser()
)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

# run
agent_executor.invoke(
    {
        "input": sys.argv[1]
    }
)
