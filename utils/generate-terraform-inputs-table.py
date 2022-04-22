#!/usr/bin/env python
import sys, hcl

with open(sys.argv[1], "r") as fp:
    try:
        obj = hcl.load(fp)
    except ValueError as e:
        print(str(e) + "\n")
        print(
            "Note: pyhcl 0.4.4 and below do not seem to support validation sections in variables."
        )
        exit(1)
    except Exception as e:
        print(str(e) + "\n")
        print("Error Loading File: " + sys.argv[1] + ", May need to update pyhcl.")
        exit(1)

    if str(obj) == "{}":
        print("Empty Variables File: " + sys.argv[1])
        exit(2)

    # Default Column Widths
    col1 = 8  # variable
    col2 = 12  # description
    col3 = 8  # type
    col4 = 8  # default
    col5 = 6  # required

    # Calculate Column Widths
    for key in obj["variable"].keys():
        default = len(str(obj["variable"][key].get("default", "")))
        description = len(str(obj["variable"][key].get("description", "")))
        data_type = len(str(obj["variable"][key].get("type", "")))
        if len(str(key)) > col1:
            col1 = len(str(key))
        if description > col2:
            col2 = min(description, 100)
        if data_type > col3:
            col3 = min(data_type, 40)
        if default > col4:
            col4 = min(default, 40)

    # Default value for Variables with no Values
    defvalue = ""
    if len(sys.argv) > 2:
        defvalue = sys.argv[2]

    # Generate Table
    print(
        "| {} | {} | {} | {} | {} |".format(
            "Name".ljust(col1),
            "Description".ljust(col2),
            "Type".ljust(col3),
            "Default".ljust(col4),
            "Required".ljust(col5),
        )
    )
    print(
        "|-{}-|-{}-|-{}-|-{}-|-{}-|".format(
            "-" * col1, "-" * col2, "-" * col3, "-" * col4, "-" * col5
        )
    )
    # print "| Name | Description | Type | Default | Required |"
    # print "|----------|---------|----------|-------------|----------|"
    for key in obj["variable"].keys():
        default = obj["variable"][key].get("default", key + "%defvalue%")
        description = obj["variable"][key].get("description", "")
        data_type = obj["variable"][key].get("type", "")
        if "default" in obj["variable"][key]:
            required = "no"
        else:
            required = "yes"

        # Indicate that a blank value is an empty String
        if str(default).strip(" ") == "":
            default = '""'
        elif default == key + "%defvalue%":
            default = defvalue

        # Indicate that a blank value for data_type is a string
        if data_type == "":
            data_type = "string"

        default = "`" + str(default) + "`"
        data_type = "`" + data_type + "`"
        default = default.replace("True", "true")
        default = default.replace("False", "false")
        print(
            "| {} | {} | {} | {} | {} |".format(
                str(key).strip(" ").ljust(col1),
                str(description).strip(" ").ljust(col2),
                str(data_type).strip(" ").ljust(col3),
                str(default).strip(" ").ljust(col4),
                str(required).strip(" ").ljust(col5),
            )
        )
