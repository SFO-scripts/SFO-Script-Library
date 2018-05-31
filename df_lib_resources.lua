--[[

_G.main_env = getfenv(1) 


--v function(level: int) --> number
function get_exp_at_level(level)
exp_to_levels_table = {
    0, 900,  1900,  3000, 4200,  5500,6870, 8370, 9940,
  11510,13080,14660, 16240,17820,19400, 20990,22580,24170,25770,27370,28980,30590,32210,
  33830,35460,37100,38740, 40390,42050,43710,45380,47060,48740,50430,52130, 53830, 55540,57260,58990,
  60730, 60730, 60730, 60730,  60730, 60730, 60730, 60730, 60730,  60730, 60730, 60730,
  60730} --:vector<number>

  return exp_to_levels_table[level]
end;
_G.get_exp_at_level = get_exp_at_level



SFOLOG("df library utilities init complete", "file.df_lib_resources")

]]