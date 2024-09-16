from fastapi import FastAPI, HTTPException
from fastapi import  Query
from typing import List, Optional
import psycopg2
from fastapi import HTTPException
from classes import Tender, TenderUpdate, Proposal, ProposalUpdate, Review, ReviewFilters, Organization
import uuid
from db import get_db_connection
from services import get_uuid_from_organization_id, get_organization_id_from_uuid
import uvicorn
app = FastAPI()


    
# Проверка доступности сервера
@app.get("/api/ping")
def ping():
    return {"status": "ok"}

@app.post("/api/organizations/new")
def create_organization(organization: Organization):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                INSERT INTO organization (name, description, type)
                VALUES (%s, %s, %s)
                RETURNING id;
            """, (organization.name, organization.description, organization.type))
            
            organization_uuid = cursor.fetchone()[0]
            print(f"Organization UUID: {organization_uuid}")  # Отладочный вывод
        
        # Коммитим изменения в базу данных до получения organization_id
        conn.commit()

        # Теперь вызываем функцию для получения целого ID
        organization_id = get_organization_id_from_uuid(organization_uuid)
        
        
        return {
            "id": organization_id,
            "name": organization.name,
            "description": organization.description,
            "type": organization.type
        }
    
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    
    finally:
        conn.close()


@app.post("/api/tenders/new")
def create_tender(tender: Tender):
    conn = get_db_connection()
    try:
        organization_uuid = get_uuid_from_organization_id(tender.organizationId)
        with conn.cursor() as cursor:
            cursor.execute("""
                INSERT INTO tenders (name, description, service_type, status, organization_id, creator_username)
                VALUES (%s, %s, %s, %s, %s, %s)
                RETURNING id;
            """, (tender.name, tender.description, tender.serviceType, tender.status, organization_uuid, tender.creatorUsername))
            
            tender_id = cursor.fetchone()[0]
            
            cursor.execute("""
                INSERT INTO tender_versions (tender_id, version, name, description, service_type, status, organization_id, creator_username)
                VALUES (%s, 1, %s, %s, %s, %s, %s, %s);
            """, (tender_id, tender.name, tender.description, tender.serviceType, tender.status, organization_uuid, tender.creatorUsername))
        
        conn.commit()
        
        return {
            "id": tender_id,
            "name": tender.name,
            "description": tender.description,
            "serviceType": tender.serviceType,
            "organizationId": tender.organizationId,
            "status": tender.status,
            "creatorUsername": tender.creatorUsername
        }
    
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    
    finally:
        conn.close()

# Получение списка тендеров
@app.get("/api/tenders")
def list_tenders(serviceType: Optional[str] = Query(None, alias="serviceType")):
    conn = get_db_connection()
    cursor = conn.cursor()

    # Если указан тип сервиса, фильтруем по нему, иначе берем все записи
    if serviceType:
        cursor.execute("SELECT * FROM tenders WHERE service_type = %s;", (serviceType,))
    else:
        cursor.execute("SELECT * FROM tenders;")
    
    # Извлекаем все записи сразу
    tenders = cursor.fetchall()

    cursor.close()
    conn.close()

   
    result = []
    for tender in tenders:
        if len(tender) < 9:
            continue
        
        organizationUuid = tender[5]
        organizationId = get_organization_id_from_uuid(organizationUuid)
        
    
        result.append({
            "id": tender[0],
            "name": tender[1],
            "description": tender[2],
            "serviceType": tender[3],
            "status": tender[4],
            "organizationId": organizationId,  
            "creatorUsername": tender[6],
            "createdAt": tender[7],
            "updatedAt": tender[8]
        })
    
    return result

@app.get("/api/tenders/my")
def get_my_tenders(username: str = Query(..., alias="username")):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM tenders WHERE creator_username = %s;", (username,))
    tenders = cursor.fetchall()
    cursor.close()
    conn.close()

    if not username:
        raise HTTPException(status_code=400, detail="Username query parameter is required")
    if not tenders:
        raise HTTPException(status_code=404, detail="Tenders not found for the given username")
    
    result = []
    for tender in tenders:
        try:
            organization_id = get_organization_id_from_uuid(tender[5])  # tender[5] - это organization_uuid
        except ValueError:
            raise HTTPException(status_code=404, detail="Organization mapping not found for this tender")
        
        result.append({
            "id": tender[0],
            "name": tender[1],
            "description": tender[2],
            "serviceType": tender[3],
            "status": tender[4],
            "organizationId": organization_id,  # Возвращаем как целое число
            "creatorUsername": tender[6],
            "createdAt": tender[7],
            "updatedAt": tender[8]
        })

    return result
    
   
@app.patch("/api/tenders/{tender_id}/edit")
def edit_tender(tender_id: int, tender_update: TenderUpdate):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT MAX(version) FROM tender_versions WHERE tender_id = %s;
            """, (tender_id,))
            
            current_version = cursor.fetchone()[0] or 0
            new_version = current_version + 1
            
            cursor.execute("""
                UPDATE tenders
                SET name = %s, description = %s
                WHERE id = %s;
            """, (tender_update.name, tender_update.description, tender_id))
            cursor.execute("""
                INSERT INTO tender_versions (tender_id, version, name, description, service_type, status, organization_id, creator_username)
                SELECT id, %s, name, description, service_type, status, organization_id, creator_username
                FROM tenders
                WHERE id = %s;
            """, (new_version, tender_id))
            
        conn.commit()

        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT id, name, description, service_type, status, organization_id, creator_username, created_at, updated_at
                FROM tenders
                WHERE id = %s;
            """, (tender_id,))
            
            updated_tender = cursor.fetchone()

        if updated_tender is None:
            raise HTTPException(status_code=404, detail="Tender not found")

        return {
            "id": updated_tender[0],
            "name": updated_tender[1],
            "description": updated_tender[2],
            "serviceType": updated_tender[3],
            "status": updated_tender[4],
            "organizationId": updated_tender[5],
            "creatorUsername": updated_tender[6],
            "createdAt": updated_tender[7],
            "updatedAt": updated_tender[8]
        }
    
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    
    finally:
        conn.close()

#откат версии тендера
@app.put("/api/tenders/{tenderId}/rollback/{version}", response_model=Tender)
def rollback_tender_version(tenderId: int, version: int):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            
            cursor.execute("""
                SELECT name, description, service_type, status, organization_id, creator_username
                FROM tender_versions
                WHERE tender_id = %s AND version = %s;
            """, (tenderId, version))
            
            tender_version = cursor.fetchone()

            if tender_version is None:
                raise HTTPException(status_code=404, detail="Version not found for the given tender ID")
            uuid_organization_id = tender_version[4]

            cursor.execute("""
                UPDATE tenders
                SET name = %s, description = %s, service_type = %s, status = %s, organization_id = %s, creator_username = %s
                WHERE id = %s;
            """, (tender_version[0], tender_version[1], tender_version[2], tender_version[3], uuid_organization_id, tender_version[5], tenderId))

            conn.commit()
          
            cursor.execute("""
                SELECT MAX(version) FROM tender_versions WHERE tender_id = %s;
            """, (tenderId,))

            current_version = cursor.fetchone()[0] or 0
            new_version = current_version + 1
            
            cursor.execute("""
                INSERT INTO tender_versions (tender_id, version, name, description, service_type, status, organization_id, creator_username)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
            """, (tenderId, new_version, *tender_version))

            conn.commit()

            cursor.execute("""
                SELECT id, name, description, service_type, status, organization_id, creator_username, created_at, updated_at
                FROM tenders
                WHERE id = %s;
            """, (tenderId,))
            
            updated_tender = cursor.fetchone()

            if not updated_tender:
                raise HTTPException(status_code=404, detail="Tender not found after rollback")

            organization_id = get_organization_id_from_uuid(updated_tender[5])

        return {
            "id": updated_tender[0],
            "name": updated_tender[1],
            "description": updated_tender[2],
            "serviceType": updated_tender[3],  
            "status": updated_tender[4],
            "organizationId": organization_id,  
            "creatorUsername": updated_tender[6], 
            "createdAt": updated_tender[7],
            "updatedAt": updated_tender[8]
        }

    except psycopg2.Error as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

    finally:
        conn.close()

@app.post("/api/bids/new", response_model=Proposal)
def create_proposal(proposal: Proposal):
    conn = get_db_connection()
    try:
       
        organization_uuid = get_uuid_from_organization_id(proposal.organization_id)
        
        
        with conn.cursor() as cursor:
            cursor.execute("""
                INSERT INTO proposals (name, description, status, tender_id, organization_id, creator_username)
                VALUES (%s, %s, %s, %s, %s, %s)
                RETURNING id;
            """, (proposal.name, proposal.description, proposal.status, proposal.tender_id, organization_uuid, proposal.creator_username))
            
            proposal_id = cursor.fetchone()[0]
            cursor.execute("""
                INSERT INTO proposal_versions (proposal_id, version, name, description, status, tender_id, organization_id, creator_username)
                VALUES (%s, 1, %s, %s, %s, %s, %s, %s);
            """, (proposal_id, proposal.name, proposal.description, proposal.status, proposal.tender_id, organization_uuid, proposal.creator_username))

        conn.commit()

        return {
            "id": proposal_id,
            "name": proposal.name,
            "description": proposal.description,
            "status": proposal.status,
            "tender_id": proposal.tender_id,
            "organization_id": proposal.organization_id, 
            "creator_username": proposal.creator_username
        }
    
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    
    except psycopg2.Error as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    
    finally:
        conn.close()

@app.get("/api/bids/my")
def get_my_proposals(username: str = Query(..., alias="username")):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM proposals WHERE creator_username = %s;", (username,))
    proposals = cursor.fetchall()
    cursor.close()
    conn.close()

    if not username:
        raise HTTPException(status_code=400, detail="Username query parameter is required")
    if not proposals:
        raise HTTPException(status_code=404, detail="Proposals not found for the given username")
    
    result = []
    for proposal in proposals:
        try:
            organization_id = get_organization_id_from_uuid(proposal[5])  # proposal[5] - это organization_uuid
        except ValueError:
            raise HTTPException(status_code=404, detail="Organization mapping not found for this proposal")
        
        result.append({
            "id": proposal[0],
            "name": proposal[1],
            "description": proposal[2],
            "status": proposal[3],
            "tender_id": proposal[4],
            "organization_id": organization_id,  # Возвращаем как целое число
            "creator_username": proposal[6],
            "createdAt": proposal[7],
            "updatedAt": proposal[8]
        })

    return result


@app.get("/api/bids/{tenderId}/list")
def get_proposals_by_tender_id(tenderId: int):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT id, name, description, status, tender_id, organization_id, creator_username, created_at, updated_at
                FROM proposals
                WHERE tender_id = %s;
            """, (tenderId,))
            
            proposals = cursor.fetchall()
            
            if not proposals:
                raise HTTPException(status_code=404, detail="No proposals found for the given tender ID")

            result = []
            for proposal in proposals:
                try:
                    # Преобразуем UUID организации в целое число
                    organization_id = get_organization_id_from_uuid(proposal[5])
                except ValueError:
                    raise HTTPException(status_code=404, detail="Organization mapping not found for this proposal")
                
                result.append({
                    "id": proposal[0],
                    "name": proposal[1],
                    "description": proposal[2],
                    "status": proposal[3],
                    "tender_id": proposal[4],
                    "organization_id": organization_id,  # Возвращаем как целое число
                    "creator_username": proposal[6],
                    "createdAt": proposal[7],
                    "updatedAt": proposal[8]
                })
            
            return result
    
    except psycopg2.Error as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    
    finally:
        conn.close()


@app.patch("/api/bids/{bidId}/edit")
def edit_proposal(bidId: int, proposal_update: ProposalUpdate):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            # Получаем текущую версию и добавляем новую
            cursor.execute("""
                SELECT MAX(version) FROM proposal_versions WHERE proposal_id = %s;
            """, (bidId,))
            current_version = cursor.fetchone()[0] or 0
            new_version = current_version + 1
            
            # Обновляем предложение
            cursor.execute("""
                UPDATE proposals
                SET name = %s, description = %s
                WHERE id = %s;
            """, (proposal_update.name, proposal_update.description, bidId))

            # Добавляем новую версию в таблицу версий
            cursor.execute("""
                INSERT INTO proposal_versions (proposal_id, version, name, description, status, tender_id, organization_id, creator_username)
                SELECT id, %s, name, description, status, tender_id, organization_id, creator_username
                FROM proposals
                WHERE id = %s;
            """, (new_version, bidId))
            
            conn.commit()

        # Получаем обновлённое предложение
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT id, name, description, status, tender_id, organization_id, creator_username, created_at, updated_at
                FROM proposals
                WHERE id = %s;
            """, (bidId,))

            updated_proposal = cursor.fetchone()

            if updated_proposal is None:
                raise HTTPException(status_code=404, detail="Proposal not found")

            # Преобразуем UUID организации в целое число
            try:
                organization_id = get_organization_id_from_uuid(updated_proposal[5])
            except ValueError:
                raise HTTPException(status_code=404, detail="Organization mapping not found for this proposal")

            # Возвращаем обновленное предложение с идентификатором организации в виде целого числа
            return {
                "id": updated_proposal[0],
                "name": updated_proposal[1],
                "description": updated_proposal[2],
                "status": updated_proposal[3],
                "tender_id": updated_proposal[4],
                "organization_id": organization_id,  # Возвращаем как целое число
                "creator_username": updated_proposal[6],
                "created_at": updated_proposal[7],
                "updated_at": updated_proposal[8]
            }
    
    except psycopg2.Error as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    
    finally:
        conn.close()

    

@app.put("/api/bids/{bidId}/rollback/{version}")
def rollback_proposal_version(bidId: int, version: int):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            # Получаем данные версии предложения
            cursor.execute("""
                SELECT name, description, status, tender_id, organization_id, creator_username
                FROM proposal_versions
                WHERE proposal_id = %s AND version = %s;
            """, (bidId, version))
            
            proposal_version = cursor.fetchone()

            if proposal_version is None:
                raise HTTPException(status_code=404, detail="Version not found for the given bid ID")
            
            # Обновляем текущее предложение до выбранной версии
            cursor.execute("""
                UPDATE proposals
                SET name = %s, description = %s, status = %s, tender_id = %s, organization_id = %s, creator_username = %s
                WHERE id = %s;
            """, (*proposal_version, bidId))

            conn.commit()

            # Получаем новую версию предложения после отката
            cursor.execute("""
                SELECT MAX(version) FROM proposal_versions WHERE proposal_id = %s;
            """, (bidId,))
            current_version = cursor.fetchone()[0] or 0
            new_version = current_version + 1
            
            # Сохраняем новую версию в таблице версий предложений
            cursor.execute("""
                INSERT INTO proposal_versions (proposal_id, version, name, description, status, tender_id, organization_id, creator_username)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
            """, (bidId, new_version, *proposal_version))
            
            conn.commit()

            # Получаем обновлённое предложение после отката
            cursor.execute("""
                SELECT id, name, description, status, tender_id, organization_id, creator_username, created_at, updated_at
                FROM proposals
                WHERE id = %s;
            """, (bidId,))
            
            updated_proposal = cursor.fetchone()

            if not updated_proposal:
                raise HTTPException(status_code=404, detail="Proposal not found after rollback")

        # Преобразуем UUID организации в целое число
        try:
            organization_id = get_organization_id_from_uuid(updated_proposal[5])
        except ValueError:
            raise HTTPException(status_code=404, detail="Organization mapping not found for this proposal")

        return {
            "id": updated_proposal[0],
            "name": updated_proposal[1],
            "description": updated_proposal[2],
            "status": updated_proposal[3],
            "tenderId": updated_proposal[4],
            "organizationId": organization_id,  # Возвращаем как целое число
            "creatorUsername": updated_proposal[6],
            "createdAt": updated_proposal[7],
            "updatedAt": updated_proposal[8]
        }

    except psycopg2.Error as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

    finally:
        conn.close()


@app.post("/api/bids/{bidId}/reviews")
def add_review(bidId: int, review: Review):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                INSERT INTO reviews (proposal_id, author_username, organization_id, review_text)
                VALUES (%s, %s, %s, %s)
                RETURNING id, proposal_id, author_username, organization_id, review_text;
            """, (bidId, review.author_username, review.organization_id, review.review_text))
            
            review_id, proposal_id, author_username, organization_id, review_text = cursor.fetchone()

            conn.commit()
            
            return {
                "id": review_id,
                "proposal_id": proposal_id,
                "author_username": author_username,
                "organization_id": organization_id,
                "review_text": review_text
            }

    except psycopg2.Error as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

    finally:
        conn.close()
   
@app.get("/api/bids/{tender_id}/reviews", response_model=List[dict])
def get_reviews(
    tender_id: int,
    authorUsername: Optional[str] = Query(None),
    organizationId: Optional[int] = Query(None)
) -> List[dict]:
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            conditions = []
            params = [tender_id]
            
            query = """
                SELECT id, proposal_id, author_username, organization_id, review_text, created_at
                FROM reviews
                WHERE proposal_id IN (
                    SELECT id FROM proposals WHERE tender_id = %s
                )
            """
            
            if authorUsername:
                conditions.append("author_username = %s")
                params.append(authorUsername)
            if organizationId:
                conditions.append("organization_id = %s")
                params.append(organizationId)
            
            if conditions:
                query += " AND " + " AND ".join(conditions)
            
            cursor.execute(query, params)
            reviews = cursor.fetchall()

            return [
                {
                    "id": row[0],
                    "proposal_id": row[1],
                    "author_username": row[2],
                    "organization_id": row[3],
                    "review_text": row[4],
                    "created_at": row[5]
                }
                for row in reviews
            ]

    except psycopg2.Error as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

    finally:
        conn.close()
