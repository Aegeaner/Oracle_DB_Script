CREATE PLUGGABLE DATABASE demodb ADMIN USER DEMO IDENTIFIED BY DEMO;

CREATE TABLESPACE DEMOTSDATA DATAFILE 'DEMOTSDATA.data' SIZE 1000M EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;
CREATE TABLESPACE DEMOTSIDX DATAFILE 'DEMOTSIDX.data' SIZE 1000M EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;

alter user DEMO identified by DEMO default tablespace DEMOTSDATA temporary tablespace TEMP profile DEFAULT;
grant select on v_$session to demo;
grant select on v_$sql_plan to demo;
grant select on v_$sql to demo;
grant select on v_$SQL_PLAN_STATISTICS_ALL to demo;
grant select on v_$sql_cursor to demo;
grant select on v_$open_cursor to demo;
grant connect to DEMO;
grant resource to DEMO;
grant ctxapp to demo;
grant select on ctxsys.dr$preference to demo;
grant execute on CTX_DDL to demo;
grant select_catalog_role to DEMO;
grant alter any sql profile to DEMO;
grant alter system to DEMO;
grant alter session to demo;
grant create any sql profile to DEMO;
grant create any table to DEMO;
grant create any view to demo;
grant create materialized view to DEMO;
grant drop any sql profile to DEMO;
grant drop any table to DEMO;
grant global query rewrite to DEMO;
grant select any table to DEMO;
grant unlimited tablespace to DEMO;

create table t_objects tablespace DEMOTSDATA as select * from dba_objects;
alter table t_objects add constraint t_objects_PK primary key (OBJECT_ID) using index  tablespace DEMOTSIDX;
create index T_OBJECTS_SUBO_IDX on T_OBJECTS (SUBOBJECT_NAME) tablespace DEMOTSIDX;
create bitmap index t_objects_idx2 on t_objects(status) tablespace DEMOTSIDX;
create bitmap index t_objects_idx4 on t_objects(owner) tablespace DEMOTSIDX;
create index t_objects_idx5 on t_objects(created) tablespace DEMOTSIDX;
create index T_OBJECTS_IDX7 on T_OBJECTS(object_type, status) tablespace DEMOTSIDX;

create table t_tables tablespace DEMOTSDATA as select * from dba_tables;
alter table t_tables add constraint t_tables_PK primary key (OWNER,TABLE_NAME) using index  tablespace DEMOTSIDX;
create index t_tables_idx1 on t_tables(OWNER) tablespace DEMOTSIDX;
create index t_tables_idx3 on t_tables(tablespace_name) tablespace DEMOTSIDX;
create index t_tables_dix01 on t_tables(table_name) INDEXTYPE IS CTXSYS.CONTEXT;

create table t_users tablespace DEMOTSDATA as select * from dba_users;
alter table t_users add constraint t_users_PK primary key (USER_ID) using INDEX tablespace DEMOTSIDX;
alter table t_users add constraint t_users_uk unique(username) using INDEX tablespace DEMOTSIDX;
create index t_users_idx1 on t_users (created)  tablespace DEMOTSIDX;

create table t_indexes tablespace DEMOTSDATA as select * from dba_indexes;
alter table t_indexes add constraint t_indexes_PK primary key (owner, index_name) using INDEX tablespace DEMOTSIDX;

create table t_xpl(tid number, tname varchar2(20), status varchar2(2), prop1 number, prop2 varchar2(30), prop3 varchar2(50)) tablespace DEMOTSDATA;
alter table t_xpl add constraint t_xpl_pk primary key (tid) using index tablespace DEMOTSIDX;

create index t_xpl_idx1 on t_xpl (tname) tablespace DEMOTSIDX;

create table t_objects_list(
    OWNER						    VARCHAR2(128),
    OBJECT_NAME					    VARCHAR2(128),
    SUBOBJECT_NAME 				    VARCHAR2(128),
    OBJECT_ID					    NUMBER,
    DATA_OBJECT_ID 				    NUMBER,
    OBJECT_TYPE					    VARCHAR2(23),
    CREATED					    DATE,
    LAST_DDL_TIME					    DATE,
    TIMESTAMP					    VARCHAR2(19),
    STATUS 					    VARCHAR2(7),
    TEMPORARY					    VARCHAR2(1),
    GENERATED					    VARCHAR2(1),
    SECONDARY					    VARCHAR2(1),
    NAMESPACE					    NUMBER,
    EDITION_NAME					    VARCHAR2(128),
    SHARING					    VARCHAR2(18),
    EDITIONABLE					    VARCHAR2(1),
    ORACLE_MAINTAINED				    VARCHAR2(1),
    APPLICATION					    VARCHAR2(1),
    DEFAULT_COLLATION				    VARCHAR2(100),
    DUPLICATED					    VARCHAR2(1),
    SHARDED					    VARCHAR2(1),
    CREATED_APPID					    NUMBER,
    CREATED_VSNID					    NUMBER,
    MODIFIED_APPID 				    NUMBER,
    MODIFIED_VSNID 				    NUMBER
)
partition by list (OWNER)
(
    partition PART1 values ('SYS')
    tablespace DEMOTSDATA,
    partition PART2 values ('DEMO')
    tablespace DEMOTSDATA,
    partition PART3 values ('WOW')
    tablespace DEMOTSDATA,
    partition PART4 values ('SYSTEM')
    tablespace DEMOTSDATA
);

insert into t_objects_list select * from dba_objects where owner in ('SYS', 'DEMO', 'WOW');
create index t_objects_list_IDX1 on t_objects_list(OBJECT_NAME) local TABLESPACE DEMOTSIDX;
create index t_objects_list_IDX2 on t_objects_list(OBJECT_ID) TABLESPACE DEMOTSIDX;
create index t_objects_list_idx3 on t_objects_list(namespace) local TABLESPACE DEMOTSIDX;

create table t_objects_RANGE
(
    OWNER						    VARCHAR2(128),
    OBJECT_NAME					    VARCHAR2(128),
    SUBOBJECT_NAME 				    VARCHAR2(128),
    OBJECT_ID					    NUMBER,
    DATA_OBJECT_ID 				    NUMBER,
    OBJECT_TYPE					    VARCHAR2(23),
    CREATED					    DATE,
    LAST_DDL_TIME					    DATE,
    TIMESTAMP					    VARCHAR2(19),
    STATUS 					    VARCHAR2(7),
    TEMPORARY					    VARCHAR2(1),
    GENERATED					    VARCHAR2(1),
    SECONDARY					    VARCHAR2(1),
    NAMESPACE					    NUMBER,
    EDITION_NAME					    VARCHAR2(128),
    SHARING					    VARCHAR2(18),
    EDITIONABLE					    VARCHAR2(1),
    ORACLE_MAINTAINED				    VARCHAR2(1),
    APPLICATION					    VARCHAR2(1),
    DEFAULT_COLLATION				    VARCHAR2(100),
    DUPLICATED					    VARCHAR2(1),
    SHARDED					    VARCHAR2(1),
    CREATED_APPID					    NUMBER,
    CREATED_VSNID					    NUMBER,
    MODIFIED_APPID 				    NUMBER,
    MODIFIED_VSNID 				    NUMBER
)
partition by range (OWNER, object_name)
(
    partition PART1 values less than ('DEMO', 'ZZZZZZ')
    tablespace DEMOTSDATA,
    partition PART2 values less than ('SYS', 'MMMMMM')
    tablespace DEMOTSDATA,
    partition PART3 values less than ('SYS', 'ZZZZZZ')
    tablespace DEMOTSDATA,
    partition PART4 values less than ('SYSMAN', 'ZZZZZZ')
    tablespace DEMOTSDATA,
    partition PART5 values less than ('SYSTEM', 'ZZZZZZ')
    tablespace DEMOTSDATA,
    partition PART6 values less than (maxvalue, maxvalue)
    tablespace DEMOTSDATA
);
insert into t_objects_range select * from t_objects_list;
create index t_objects_range_idx1 on t_objects_range(object_name) local TABLESPACE DEMOTSIDX;
create index t_objects_range_idx2 on t_objects_range(created) local TABLESPACE DEMOTSIDX;

create table t_objects_hash
(
    OWNER						    VARCHAR2(128),
    OBJECT_NAME					    VARCHAR2(128),
    SUBOBJECT_NAME 				    VARCHAR2(128),
    OBJECT_ID					    NUMBER,
    DATA_OBJECT_ID 				    NUMBER,
    OBJECT_TYPE					    VARCHAR2(23),
    CREATED					    DATE,
    LAST_DDL_TIME					    DATE,
    TIMESTAMP					    VARCHAR2(19),
    STATUS 					    VARCHAR2(7),
    TEMPORARY					    VARCHAR2(1),
    GENERATED					    VARCHAR2(1),
    SECONDARY					    VARCHAR2(1),
    NAMESPACE					    NUMBER,
    EDITION_NAME					    VARCHAR2(128),
    SHARING					    VARCHAR2(18),
    EDITIONABLE					    VARCHAR2(1),
    ORACLE_MAINTAINED				    VARCHAR2(1),
    APPLICATION					    VARCHAR2(1),
    DEFAULT_COLLATION				    VARCHAR2(100),
    DUPLICATED					    VARCHAR2(1),
    SHARDED					    VARCHAR2(1),
    CREATED_APPID					    NUMBER,
    CREATED_VSNID					    NUMBER,
    MODIFIED_APPID 				    NUMBER,
    MODIFIED_VSNID 				    NUMBER
)
partition by hash (OWNER) PARTITIONS 6
tablespace DEMOTSDATA;
insert into t_objects_hash select * from t_objects_list;
create index t_objects_hash_idx1 on t_objects_hash(object_name) LOCAL TABLESPACE DEMOTSIDX;

create table t_tables_list
partition by list (OWNER)
(
    partition PART1 values ('SYS')
    tablespace DEMOTSDATA,
    partition PART2 values ('DEMO')
    tablespace DEMOTSDATA,
    partition PART3 values ('WOW')
    tablespace DEMOTSDATA
)
as select * from t_tables
where OWNER in ('SYS','DEMO','WOW');

create table t_constraints tablespace DEMOTSDATA as
select owner,constraint_name,constraint_type,table_name,r_owner,r_constraint_name,status,deferrable,deferred,validated,generated,bad,rely,last_change,index_owner,index_name,invalid,view_related
from dba_constraints;

create bitmap index t_constraints_idx1 on t_constraints(owner) tablespace DEMOTSIDX;
create index t_constraints_idx2 on t_constraints(r_owner) tablespace DEMOTSIDX;

CREATE CLUSTER C_KEY2 (A NUMBER);
create table T_EEE(
    a NUMBER,
    b VARCHAR2(20),
    c NUMBER not null
)cluster C_KEY2 (A);
CREATE CLUSTER C_KEY1 (C NUMBER) SIZE 512 HASHKEYS 10;
create table T_AAA(
    a NUMBER,
    b VARCHAR2(20),
    c NUMBER not null
)cluster C_KEY1 (C);
create table T_DDD(
    a NUMBER,
    b VARCHAR2(20),
    c NUMBER not null
)cluster C_KEY1 (C);

create materialized view mv_tables as
select t.owner, t.table_name, t.tablespace_name, o.created, o.last_ddl_time
from t_tables t, t_objects o
where t.owner = o.owner and t.table_name = o.object_name and o.object_type = 'TABLE' and t.tablespace_name is not null;
create unique index mv_tables_idx1 on mv_tables(owner, table_name) tablespace DEMOTSIDX;

alter table T_TABLESPACES add constraint T_TABLESPACE_PK primary key (TABLESPACE_NAME) using index tablespace DEMOTSIDX;
alter table t_tables add constraint t_tables_ts_fk foreign key (tablespace_name) references t_tablespaces(tablespace_name);

create table t_datafiles tablespace DEMOTSDATA as select * from dba_data_files;
alter table t_datafiles add constraint t_datafiles_pk primary key (file_id) using index tablespace DEMOTSIDX;

create table t_tables_sub1 tablespace DEMOTSDATA as select * from t_tables where owner='DEMO';
create table t_tables_sub2 tablespace DEMOTSDATA as select * from t_tables where owner='SYS';
create or replace view v_tables as select * from t_tables_sub1 union all select * from t_tables_sub2;

create or replace TYPE phone AS OBJECT (telephone NUMBER)
/
create or replace TYPE phone_list AS TABLE OF phone
/
CREATE OR REPLACE FUNCTION GET_PHONELIST
RETURN PHONE_LIST AS
BEGIN
    RETURN phone_list(phone(111111),phone(2222222),phone(333333));
END GET_PHONELIST;
/

create or replace view v_objects_sys as select owner, object_name, subobject_name, status, created, last_ddl_time from t_objects where owner = 'SYS';
create or replace view v_objects_sum as select owner, count(object_name) as objnum from t_objects group by owner;

create global temporary table tmp_lob(b clob);
create table t_histhead tablespace DEMOTSDATA as select * from sys.hist_head$;
create table t_sqlplans tablespace DEMOTSDATA as select * from dba_hist_sql_plan;
create table t_tab_bak tablespace DEMOTSDATA as select * from t_tables;
create table t_sesstat tablespace DEMOTSDATA as select * from v$sesstat;
