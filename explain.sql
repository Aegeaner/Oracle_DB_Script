create or replace procedure sql_explain (stmt varchar2,
    format varchar2 default 'ADVANCED',
    exponly boolean default true)
AUTHID CURRENT_USER
as
c number;
r number;
sqlid varchar2(100);
childnum number;
begin
    dbms_output.enable(50000);
    if exponly then
        execute immediate 'explain plan for '||stmt;
        for xpl_rec in ( select * from table(dbms_xplan.display(null,null,format)) ) loop
            dbms_output.put_line(xpl_rec.plan_table_output);
        end loop;
    else
        c := dbms_sql.open_cursor;
        dbms_sql.parse(c,stmt,dbms_sql.native);
        r := dbms_sql.execute_and_fetch(c);
        loop
            exit when r <= 0;
            r := dbms_sql.fetch_rows(c);
        end loop;
        select distinct p.sql_id, p.child_number into sqlid, childnum
        from v$sql_cursor sc, v$sql_plan p, v$open_cursor c, v$sqlarea q
        where p.address=sc.PARENT_HANDLE and p.sql_id=q.sql_id and c.sql_id = q.sql_id and c.sid = SYS_CONTEXT('USERENV','SID') and q.sql_text like substr(stmt,0,30)||chr(37) and rownum<=1;
        --select distinct s.sql_id, s.child_number into sqlid, childnum from v$sql_plan s, v$sql_cursor c where s.address=c.PARENT_HANDLE and c.curno=c and rownum<=1;
        dbms_sql.close_cursor(c);
        for xpl_rec in ( select * from table(dbms_xplan.display_cursor(sqlid,childnum,format)) ) loop
            dbms_output.put_line(xpl_rec.plan_table_output);
        end loop;
    end if;
    rollback;
end;
/

grant execute on sql_explain to public;
create or replace public synonym sql_explain for sys.sql_explain;
set serveroutput on;
