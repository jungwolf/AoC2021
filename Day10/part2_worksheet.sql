-- first thing, modify the function to return the closures for incomplete strings


-- haven't modified it yet
create or replace function missing_closers(p_input varchar2) return varchar2 as
-- return null if there is an error in the input
-- otherwise, return the missing closers
-- that will also be null if the string is balanced

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
--dbms_output.put_line('input:'||input||' stack:'||stack||' i:'||i);
    -- set up for next comparison
    a := substr(input,1,1);
    input := substr(input,2);
    i := length(input);
    an := instr(openers,a);
    
--dbms_output.put_line('a:'||a||' an:'||an);
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
--dbms_output.put_line('b:'||b||' bn:'||bn||' a:'||a||' an:'||an);
      if an != bn or bn is null then
        return a;
      end if;
    end if;

  end loop;

  -- hmm, no bad matches
  return null;
end;
/

