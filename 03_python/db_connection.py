from sqlalchemy import create_engine
from config import DB_CONFIG


def get_engine():

    connection_string = (
        f"mysql+pymysql://"
        f"{DB_CONFIG['username']}:"
        f"{DB_CONFIG['password']}@"
        f"{DB_CONFIG['host']}:"
        f"{DB_CONFIG['port']}/"
        f"{DB_CONFIG['database']}"
    )

    engine = create_engine(connection_string)

    return engine