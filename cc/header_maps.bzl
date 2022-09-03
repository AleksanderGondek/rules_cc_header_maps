""" To be described. """

HdrMapsInfo = provider(
    doc = "",
    fields = {
        "public_hdrs": "To be described",
        "private_hdrs": "To be described",
        "header_maps": "To be described, string_list_dict"
    }
)

def materialize_hdrs_mapping(
    actions,
    header_maps,
    hdrs
):
    """ To be described. """
    materialized_include_path = None
    materialized_hdrs_files = []

    for pattern, mappings in header_maps.items():
        for header_file in hdrs:
            if pattern != header_file.path:
                continue

            for mapping in mappings:
                # TODO: Hash the label name and add as prefix?
                mapping_path = "/".join([
                    "header_maps",
                    mapping
                ])
                mapping_file = actions.declare_file(
                    mapping_path
                )
                actions.run_shell(
                    outputs = [mapping_file],
                    inputs = [header_file],
                    # This adds '' before cp command, causing it to fail...
                    # arguments = [
                    #     header_file.path,
                    #     mapping_file.path
                    # ],
                    command = "cp {} {}".format(header_file.path, mapping_file.path),
                    progress_message = "Materializing public hdr mapping from '%{input}' to '%{output}'"
                )
                materialized_hdrs_files.append(mapping_file)


    if materialized_hdrs_files:
        hdr = materialized_hdrs_files[0]
        materialized_include_path = hdr.path.replace(
            hdr.basename, ""
        )

    return materialized_include_path, materialized_hdrs_files

def merge_header_maps(
    hdr_maps_one,
    hdr_maps_two
):
    """ To be described. """
    final_mappings = {}
    for pattern, mappings in hdr_maps_one.items():
        if pattern not in final_mappings:
            final_mappings[pattern] = []

        for mapping in mappings:
            if mapping in final_mappings[pattern]:
                continue

            final_mappings[pattern].append(mapping)

    for pattern, mappings in hdr_maps_two.items():
        if pattern not in final_mappings:
            final_mappings[pattern] = []

        for mapping in mappings:
            if mapping in final_mappings[pattern]:
                continue

            final_mappings[pattern].append(mapping)

    return final_mappings
