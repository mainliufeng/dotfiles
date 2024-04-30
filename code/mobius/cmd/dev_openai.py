import sys

from langchain.agents import AgentExecutor
from mobius.cases.dev import tools, llm

from langchain import hub
from langchain.agents import AgentExecutor, create_tool_calling_agent

# prompt
prompt = hub.pull("hwchase17/openai-tools-agent")
prompt.pretty_print()

# agent
agent = create_tool_calling_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

# run
agent_executor.invoke(
    {
        "input": sys.argv[1]
    }
)
