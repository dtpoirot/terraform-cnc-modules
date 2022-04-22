# Terraform inputs documentation: variables.tf -> markdown tables

This tiny program parses the variables.tf file included in
the each cloud provider specific folder to generate documentation for all parameters listed
in the variables.tf file.

# How to generate the input tables

1. Install the pyhcl package.
2. Run the generate-terraform-inputs-table.py script like below.

```bash
./generate-terraform-inputs-table.py ../2022.6/azure/global-resources/variables.tf
./generate-terraform-inputs-table.py ../2022.6/azure/environment/variables.tf
```

3. Update the respective cloud provider readme file with the above output.