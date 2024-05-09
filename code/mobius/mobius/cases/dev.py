import os

from langchain_openai import ChatOpenAI
from langchain_core.messages import AIMessage
from langchain_core.runnables import Runnable

from mobius.tools.qianxun import qianxun_file_search
from mobius.tools.sql import get_create_statements
from mobius.tools.shell import shell_tool
from mobius.tools.python import python_repl_tool
from mobius.tools.duckduckgo import duckduckgo_search
from mobius.tools.url_loader import url_loader

tools = [qianxun_file_search, 
         get_create_statements, 
         duckduckgo_search,
         shell_tool,
         python_repl_tool,
         url_loader]

model = os.environ["OPENAI_DEFAULT_MODEL"]
if not model:
    model = "gpt-4-turbo"

llm = ChatOpenAI(model=model, temperature=0.4)

def human_approval(msg: AIMessage) -> Runnable:
    tool_strs = '\n\n'.join([
        f'工具：{tool_call["name"]}\n参数：{tool_call["args"]}' 
        for tool_call in msg.tool_calls 
        if tool_call["name"] in [shell_tool.name, python_repl_tool.name]
        ])
    if not tool_strs:
        return msg

    input_msg = (f"是否授权执行下面工具\n\n{tool_strs}\n\n"
                 "任何非'Y'/'Yes' (大小写不敏感) 都会被视为拒绝：")
    resp = input(input_msg)
    if resp.lower() not in ("yes", "y"):
        raise ValueError(f"拒绝执行工具:\n\n{tool_strs}")
    return msg

llm_with_tools = llm.bind_tools(tools)
