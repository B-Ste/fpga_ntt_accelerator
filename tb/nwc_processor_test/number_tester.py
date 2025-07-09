def read_numbers_from_file(filename):
    with open(filename, 'r') as file:
        return set(line.strip() for line in file if line.strip())

def compare_files(file1, file2):
    numbers1 = read_numbers_from_file(file1)
    numbers2 = read_numbers_from_file(file2)

    if numbers1 == numbers2:
        print("The files contain the same numbers.")
    else:
        print("The files do NOT contain the same numbers.")
        print(f"Only in {file1}: {numbers1 - numbers2}")
        print(f"Only in {file2}: {numbers2 - numbers1}")

# Replace these with your actual filenames
file1 = 'trace.txt'
file2 = 'tracing.txt'

compare_files(file1, file2)
