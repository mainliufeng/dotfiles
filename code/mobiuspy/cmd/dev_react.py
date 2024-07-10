from langchain import hub
from langchain_community.llms import OpenAI
from langchain.agents import AgentExecutor, create_react_agent

from langchain.agents import AgentExecutor
from mobius.cases.dev import tools

# ReAct
prompt = hub.pull("hwchase17/react")
model = OpenAI()

# agent
agent = create_react_agent(model, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

import sys
import datetime
today = datetime.datetime.now().date()
user_input = sys.argv[1]
input = f"今天是{today}，地点是北京\n{user_input}"
print(input)
result = agent_executor.invoke({
    "input": input,
})
print(result)
