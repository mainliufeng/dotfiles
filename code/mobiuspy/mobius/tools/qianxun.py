import os
from langchain.tools import tool
import requests
from langchain.pydantic_v1 import BaseModel, Field

class QianxunFileSearchInput(BaseModel):
    query: str = Field(description="""搜索query，直接使用用户当前输入的问题""")

@tool("qianxun-file-search", args_schema=QianxunFileSearchInput)
def qianxun_file_search(query: str) -> str:
    """千循知识库搜索"""
    resp = _search(query)
    return "\n\n".join(['文件：' + item["file"]["name"] + '\n内容：' + item["text"] + '\n' for item in resp["items"]])

def _search(query: str):
    url = f'{os.getenv("QIANXUN_BASE_URL")}/api/file/chunk/search'
    headers = {
        'authorization': f'Bearer {os.getenv("QIANXUN_ACCESS_TOKEN")}',
        'content-type': 'application/json'
    }
    data = {
        "file_ids": [""],
        "q": query,
        "top_k": 10
    }
    response = requests.post(url, headers=headers, json=data)
    return response.json()
