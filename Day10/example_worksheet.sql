-- create the find_first_bad_closer() function

-- create the find_first_bad_closer() function
create or replace function find_first_bad_closer(p_input varchar2) return varchar2 as
-- return null if no bad closer, including incomplete openers
  input varchar2(4000) := p_input;
  stack varchar2(4000);
  openers varchar2(4) := '([{<';
  closers varchar2(4) := ')]}>';
  i number;
  a varchar2(1);
  b varchar2(2);
  an number;
  bn number;
begin
  i := length(input);

  while i > 0 loop
dbms_output.put_line('input:'||input||' stack:'||stack||' i:'||i);
    -- set up for next comparison
    a := substr(input,1,1);
    input := substr(input,2);
    i := length(input);
    an := instr(openers,a);
    
dbms_output.put_line('a:'||a||' an:'||an);
    -- is the new value an opener, 0 if no
    if an > 0 then
	  -- push on the stack
      stack := stack || a;
    else
	 -- do all the work on the pop
 	 an := instr(closers,a);
      b := substr(stack,-1,1);
      stack := substr(stack,1,length(stack)-1);
      bn := instr(openers,b);
dbms_output.put_line('b:'||b||' bn:'||bn||' a:'||a||' an:'||an);
      if an != bn or bn is null then
        return a;
      end if;
    end if;

  end loop;

  -- hmm, no bad matches
  return null;
end;
/

select find_first_bad_closer('[]') from dual;
select find_first_bad_closer('[]>') from dual;
select find_first_bad_closer('[>]') from dual;

select * from day10_example;
select linevalue, find_first_bad_closer(linevalue) from day10_example;
select linevalue, find_first_bad_closer(linevalue) from day10_example
where lineno = 1;

/*
select 
  linevalue
  , find_first_bad_closer(linevalue) 
  , decode(find_first_bad_closer(linevalue), ')',3, ']',57, '}',1197, '>',25137, 0)
from day10_example;
*/

select sum(errcodes) from (
select 
  linevalue
  , find_first_bad_closer(linevalue) 
  , decode(find_first_bad_closer(linevalue), ')',3, ']',57, '}',1197, '>',25137, 0) errcodes
from day10_example
);
