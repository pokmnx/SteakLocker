package com.steaklocker.steaklocker.models;

import java.util.Date;
import java.util.StringTokenizer;

import io.realm.RealmObject;
import io.realm.annotations.Index;
import io.realm.annotations.PrimaryKey;


public class ParseRlmObject extends RealmObject
{
    @PrimaryKey
    @Index
    protected String          uuid;
    @Index
    protected String          objectId;

    protected Date            createdAt;
    protected Date            updatedAt;


    public String   getUuid() { return this.uuid; }
    public void     setUuid(String uuid) { this.uuid = uuid; }

    public String   getObjectId() { return this.objectId; }
    public Date getCreatedAt() { return this.createdAt; }
    public Date getUpdatedAt() { return this.updatedAt; }

    public boolean isObjectId(String objectId)
    {
        return this.objectId.equals(objectId);
    }
}