import re
from collections import defaultdict

def parse_file(filename):
    # Dictionary: key = (m, j, k, r_label), value = r_value
    data = {}
    pattern = re.compile(r"m=(\d+)\s+j=(\d+)\s+k=(\d+)\s+(r[1-4])=(\d+)")
    
    with open(filename, 'r') as f:
        for line in f:
            match = pattern.search(line)
            if match:
                m, j, k, r_label, r_value = match.groups()
                key = (int(m), int(j), int(k), r_label)
                data[key] = int(r_value)
    return data

def compare_data(data1, data2):
    all_keys = set(data1.keys()) | set(data2.keys())
    differences = []

    for key in sorted(all_keys):
        val1 = data1.get(key, None)
        val2 = data2.get(key, None)
        if val1 != val2:
            differences.append((key, val1, val2))

    return differences

def main(file1, file2):
    data1 = parse_file(file1)
    data2 = parse_file(file2)
    diffs = compare_data(data1, data2)

    if diffs:
        print("Differences found:")
        for (m, j, k, r_label), val1, val2 in diffs:
            print(f"m={m} j={j} k={k} {r_label}: file1={val1} file2={val2}")
    else:
        print("No differences found.")

# Example usage
if __name__ == "__main__":
    main("tb/processor_test/tracing.txt", "tb/processor_test/output.txt")
