###############################################################################
# Do Hoon Kiem gatto@kaist.ac.kr
# 2024.05
# Last update: 2025.03
# https://kaist-elst.github.io/DFTforge.jl/
# https://dhkiem.github.io/SpinMax.jl
# SpinMax.jx2spinmax(atom1, atom2, root_dir; toml = tomlfile)
# e.g. SpinMax.jx2spinmax([1,2], [1,2], jx2.col.spin_0.0; toml = "MFT.toml")
###############################################################################

module jx2spinmax

export create


const readme1 = "jx2spinmax: https://github.com/DHKiem/jx2spinmax"
const readme2 = "SpinMax: https://github.com/KAIST-ELST/SpinMax_dev.jl"
const readme3 = "DFTforge: https://github.com/KAIST-ELST/DFTforge.jl.git"
const readme4 = "USE: jx2spinmax.create(atom1, atom2, jxdir; toml=TOMLFILE)\n e.g. jx2spinmax.create([1,2], [1,2], \"jx2.col.spin_0.0\"; toml=\"MFT.toml\")"


function __init__()
    println("$readme1")
    println("$readme2")
    println("$readme3")
    println("$readme4")

end

import Glob
import FileIO
using ArgParse
#import SpinMax
import TOML
  
function create(atom1list, atom2list, root_dir; toml=Nothing)
    println("================ User input =============")
    println(atom1list)
    println(atom2list)
    println(root_dir)
    println(toml)

    # get file list
    orbital_name = "all_all"
    file_list = Array{String}(undef,0);
    file_list_csv = Array{String}(undef,0);
    for atom1_name in atom1list
        for atom2_name in atom2list
            atom_12name = string(atom1_name) * "_" * string(atom2_name)
            #file_list_tmp = Glob.glob(joinpath(root_dir,"*_" * atom_12name * "_*" * orbital_name * "*.jld2") )
            #file_list_csv_tmp = Glob.glob(joinpath(root_dir,"*_" * atom_12name * "_*" * orbital_name * "*.csv") )
            file_list_tmp = Glob.glob("*_" * atom_12name * "_*" * orbital_name * "*.jld2", root_dir )
            file_list_csv_tmp = Glob.glob("*_" * atom_12name * "_*" * orbital_name * "*.csv", root_dir )
  
            append!(file_list,file_list_tmp)
            append!(file_list_csv,file_list_csv_tmp)
        end
    end
    sort!(file_list)
    sort!(file_list_csv)

    #cached_mat_dict = Dict{Tuple{Int64,Int64},Any}();
    
    #global rv = zeros(Float64, 3,3)
    #global tv = zeros(Float64, 3,3)
    #global global_xyz = [];
    #global atom1 = 0
    #global atom2 = 0
    
    
    for (v_filename,v_filename_csv) in zip(file_list,file_list_csv)
        #s = MAT.matread(v_filename);
        println(v_filename)
        println(v_filename_csv)
        local s = FileIO.load(v_filename);
        
        global atom1 = s["atom1"];
        global atom2 = s["atom2"];
        global cal_name = s["cal_name"];
        global rv = s["rv"];
        global tv = s["tv"];
        global global_xyz = s["Gxyz"];
        global atomnum = s["atomnum"]; ## add
        #println("atomnum ", atomnum)
        println("rv ", rv)
               
    end
    
    ##########################  Read input from argument & TOML file
    if !(Nothing == toml)
    println("================ TOML files =============")
    println(toml)
    arg_input = TOML.parsefile(toml)
    kn = arg_input["bandplot"]["kPoint_step"]
    kPath_list = arg_input["bandplot"]["kPath_list"]
    kgrids = arg_input["k_point_num"]
    println(kgrids)
    kpaths = [ kn kPath_list[1][1][1] kPath_list[1][1][2] kPath_list[1][1][3] kPath_list[1][2][1] kPath_list[1][2][2] kPath_list[1][2][3] ]
    for (i,kpath1) in enumerate(kPath_list)
        if i == 1
            continue
        end
        global kpaths = vcat(kpaths, [kn kpath1[1][1] kpath1[1][2] kpath1[1][3] kpath1[2][1] kpath1[2][2] kpath1[2][3]] )
    end
    println("kpaths\n", kpaths, "\n", typeof(kpaths))
    end
    ############################
    #global tv
    lattice_vec = [
        tv[1,1:3],
        tv[2,1:3],
        tv[3,1:3]
    ]
    
    NumAtom = atomnum
    AtomPosSpins = [
        [vec(transpose(global_xyz[i,1:3])/tv), [1], [0,0]] for i in 1:atomnum ### need to find up and down spins 
    ]
    println("lattice_vec\n",lattice_vec)
    println("NumAtom\n", NumAtom)
    println("AtomPosSpins\n", AtomPosSpins)
        
        
    NumAtom_cal = length(atom1list)
    #AtomPosSpins2 = AtomPosSpins[parse.(Int64,atom1_name_list)]
    AtomPosSpins2 = AtomPosSpins[atom1list]
    println("AtomPosSpins2\n", AtomPosSpins2)
    #exchanges = SpinMax.jx_exchange_col(root_dir, cal_name,vec([[a1, a2] for a1 in atom1list , a2 in atom2list ]))
        
        
    println("================ spinmax_param.jl Creating =============")
        
    F = open("spinmax_param.jl","w")
    write(F,"import SpinMax\n\n")
    write(F,"NumAtom = ")
    #write(F,string(NumAtom)*"\n\n")
    write(F,string(length(atom1list))*"\n\n")
        
    write(F,"lattice_vec = \n")
    write(F,string(lattice_vec)*"\n\n")
        
    write(F,"AtomPosSpins = [\n")
    for a1 in atom1list
        #write(F, string(AtomPosSpins[parse(Int64,atom1_name)])*", \n" )
        write(F, string(AtomPosSpins[a1])*", \n" )
    end
    write(F, "]\n\n")
    #write(F,string(AtomPosSpins)*"\n\n\n")
        
    write(F,"#[atom1, atom2], [a1,a2,a3], [J1,J2,J3,J4,J5,J6,J7,J8,J9]\n")
    write(F,"exchanges = SpinMax.jx_exchange_col(\""*root_dir*"/\",\""*cal_name*"\",[\n")
    write(F," "^13)
    for a1 in atom1list
        for a2 in atom2list
            atom_12name = "["*string(a1) * "," * string(a2)*"], "
            write(F, atom_12name)
        end
    end
    write(F, "\n"*" "^13*"])\n")
        
        #for v_file_csv in file_list_csv
        #  write(F,"  SpinMax.jx_col(\""*v_file_csv*"\",1),\n")
        #end
        #write(F,"]\n")
        
    if !(Nothing == toml)
    write(F,"\n\nkpaths = ")
    write(F,string(kpaths))
    write(F, "\n\nkgrids = ")
    write(F,string(kgrids))
    #kgrids = [5,5,5]
    end
    write(F, "\n# magnon band calculation\n#SpinMax.band(lattice_vec, NumAtom, AtomPosSpins, exchanges, kpaths)\n\n")
        
    write(F, "\n# magnon dos calculation\n#SpinMax.dos(lattice_vec, NumAtom, AtomPosSpins, exchanges, kgrids, Emin = 0.0, Emax = 20.0, Egrid = 0.1)\n\n")
        
        
    close(F)
        
    if !(Nothing == toml)
    println("================ spinmax_param.jl created =============")
    #SpinMax.band(lattice_vec, NumAtom_cal, AtomPosSpins2, exchanges, kpaths)
    else
        println("SKIP SpinMax band calculation due to No declaration of k-path.")
        println("If you want to create band-path using this script, write bandpath in .toml file and use --toml keyword. ")
        println("  e.g.: \"")
        println("  [bandplot]")
        println("bandplot = false")
        println("kPoint_step = 10")
        println("kPath_list = [")
        println("  [ [0.0,   0.0,   0.0], [0.5,   0.0,   0.0], [\"G\", \"X\"] ], ")
        println("]\"")
        println("or Add band path in spinmax_param.jl \ne.g.")
        println("kpaths = [
        20    0.0 0.0 0.0   0.5 0.0 0.0")
        println("]")
    end
    
end


end # module jx2spinmax
