import psycopg2
from typing import List, Optional
from main import get_db_connection
    
def get_uuid_from_organization_id(organization_id: int) -> str:
    conn = get_db_connection()
    with conn.cursor() as cursor:
        cursor.execute("SELECT uuid FROM organization_mapping WHERE organization_id = %s", (organization_id,))
        result = cursor.fetchone()
        if result:
            return result[0]
        else:
            raise ValueError("Organization ID not found")
        
def get_organization_id_from_uuid(uuid: str) -> int:
    conn = get_db_connection()
    with conn.cursor() as cursor:
        cursor.execute("SELECT organization_id FROM organization_mapping WHERE uuid = %s", (uuid,))
        result = cursor.fetchone()
        
        if result:
            return result[0]
        else:
            raise ValueError("UUID not found in organization mapping")
        
        
def get_tenders(service_type: Optional[str] = None):
    conn = get_db_connection()
    cursor = conn.cursor()
    if service_type:
        cursor.execute("SELECT * FROM tenders WHERE service_type = %s;", (service_type,))
    else:
        cursor.execute("SELECT * FROM tenders;")
    tenders = cursor.fetchall()
    cursor.close()
    conn.close()
    return tenders