CREATE LUA SCRIPT "GM_WRAPPER_SCRIPT_RCD" () RETURNS ROWCOUNT AS
import( 'olap.gmpreprocessorscript_rcd', 'gmpreprocessorscript_rcd') -- second parameter is just an alias 
sqlparsing.setsqltext(
gmpreprocessorscript_rcd.gm_preprocessor_function_rcd(sqlparsing.getsqltext()))
/
