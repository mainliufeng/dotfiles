import sys

from langchain.agents import AgentExecutor
from mobius.cases.dev import tools, llm_with_tools, human_approval

from langchain.agents import AgentExecutor
from langchain.agents.format_scratchpad.tools import (
    format_to_tool_messages,
)
from langchain.agents.output_parsers.tools import ToolsAgentOutputParser
from langchain_core.runnables import RunnablePassthrough
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

# prompt
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "你是一个AI助手"),
        ("user", "{input}"),
        MessagesPlaceholder(variable_name="agent_scratchpad"),
    ]
)

# agent
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
ret = agent_executor.invoke(
    {
        "input": sys.argv[1]
    }
)
print(ret['output'])
