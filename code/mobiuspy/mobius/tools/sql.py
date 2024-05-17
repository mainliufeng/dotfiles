from langchain.tools import tool

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.sql import text

databases_file = '/home/liufeng/dotfiles-private/databases.properties'

@tool
def get_create_statements() -> str:
    """获取数据库中所有表的CREATE TABLE语句"""
    engine: Engine = create_engine(get_connection_string(databases_file))
    try:
        with engine.connect() as connection:
            result = connection.execute(text("SHOW TABLES;"))
            tables = result.fetchall()
            create_statements = []
            for table in tables:
                table_name = table[0]
                create_table_result = connection.execute(text(f"SHOW CREATE TABLE {table_name};"))
                create_table_statement = create_table_result.fetchone()[1]
                create_statements.append(create_table_statement)
    except SQLAlchemyError as e:
        raise Exception(f"SQLAlchemy Error: {e}")
    finally:
        engine.dispose()
    return "\n\n".join(create_statements)

def get_connection_string(databases_file_path) -> str:
    """
    Reads the 'databases.properties' file, shows keys using rofi,
    and returns the connection string of the selected database.
    """
    import subprocess

    # Load the properties file
    with open(databases_file_path, 'r') as file:
        lines = file.readlines()
        keys = [line.split('=')[0] for line in lines if '=' in line]

    # Prepare the keys for selection
    process = subprocess.run(['rofi', '-dmenu', '-p', 'Select Database', '-font', 'hack 38'], input='\n'.join(keys), capture_output=True, text=True)
    selected_key = process.stdout.strip()

    # Return the selected connection string
    for line in lines:
        key_value = line.split('=')
        if key_value[0] == selected_key:
            return key_value[1].strip()
    raise ValueError("No valid database selected")
