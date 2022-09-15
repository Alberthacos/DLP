
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name Contador_objetos -dir "C:/Users/amf01/Documents/DLP/P2/Contador_objetos/planAhead_run_2" -part xc6slx9ftg256-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/amf01/Documents/DLP/P2/Contador_objetos/Control.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/amf01/Documents/DLP/P2/Contador_objetos} }
set_property target_constrs_file "Restricciones.ucf" [current_fileset -constrset]
add_files [list {Restricciones.ucf}] -fileset [get_property constrset [current_run]]
link_design
