import re

def parse_line(line):
    """Parses a line and returns a tuple (m, j, k, r_label, r_value)"""
    match = re.match(r"m=(\d+)\s+j=(\d+)\s+k=(\d+)\s+(r\d)=(\d+)", line.strip())
    if match:
        m, j, k, r_label, r_value = match.groups()
        return (int(m), int(j), int(k), r_label, int(r_value))
    return None

def load_file(filepath):
    """Loads file and returns a dictionary with keys as (m, j, k, r_label) and values as r_value"""
    data = {}
    with open(filepath, 'r') as f:
        for line in f:
            parsed = parse_line(line)
            if parsed:
                m, j, k, r_label, r_value = parsed
                key = (m, j, k, r_label)
                data[key] = r_value
    return data

def compare_files(file1, file2):
    data1 = load_file(file1)
    data2 = load_file(file2)

    all_keys = set(data1.keys()).union(data2.keys())

    for key in sorted(all_keys):
        val1 = data1.get(key)
        val2 = data2.get(key)
        if val1 != val2:
            m, j, k, r_label = key
            print(f"Difference at m={m} j={j} k={k} {r_label}: tracing={val1} out={val2}")

# Run the comparison
compare_files("tb/intt_processor_test/tracing.txt", "tb/intt_processor_test/out.txt")
