import os

from langchain.tools.ddg_search import DuckDuckGoSearchRun
from langchain_openai import ChatOpenAI

from mobius.tools.qianxun import qianxun_file_search
from mobius.tools.sql import get_create_statements

tools = [qianxun_file_search, 
         get_create_statements, 
         DuckDuckGoSearchRun()]

model = os.environ["OPENAI_DEFAULT_MODEL"]
if not model:
    model = "gpt-4-turbo"

llm = ChatOpenAI(model=model, temperature=0.7)

