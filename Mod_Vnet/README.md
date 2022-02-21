# Module notes
This module is used to create a virtual network in the a resource group and location that you choice. You will pass in the number of subnets you need using a number. The subnets are dynamicaly created using the meta-aurgument and cidrsubnet function.

# Quality Audit Notes
## Standard Module Structure
Root module - The module must exist in the root directory. This should be the primary entry point for the module.

README - Modules and every repository should contain a README.md file explaining the purpose of the module or repository.

License - The license under which this module is available. If you are publishing a module publicly, many organizations will not adopt a module unless a clear license is present. We recommend always having a license file, even if it is not an open source license.

File Names - The recommended filenames for a module at a minimum are main.tf, variables.tf, and output.tf
