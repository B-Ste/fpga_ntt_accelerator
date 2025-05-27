all:
	@echo "Valid make targets are:"
	@echo " open   - to open the created project"
	@echo " build  - to create the project"	
	@echo " clean  - to delete the created project"

build: project

project : 
	vivado -mode batch -source tcl/build_project.tcl

open: 
	vivado project_ntt_accelerator/project_ntt_accelerator.xpr -source tcl/custom_commands.tcl -tempDir /tmp &

clean:
	rm -rf vivado.* vivado_* .Xil/ webtalk* hs_err* -f
	rm -rf project_ntt_accelerator 
