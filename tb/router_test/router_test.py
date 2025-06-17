# curtesy of chatGPT

# Compare lines from f1.txt and f2.txt
def compare_files(file1, file2):
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        lines1 = f1.readlines()
        lines2 = f2.readlines()

    max_lines = max(len(lines1), len(lines2))

    for i in range(max_lines):
        try:
            num1 = float(lines1[i].strip())
        except IndexError:
            print(f"Line {i + 1}: {file1} has no more lines.")
            continue
        except ValueError:
            print(f"Line {i + 1}: Invalid number in {file1}.")
            continue

        try:
            num2 = float(lines2[i].strip())
        except IndexError:
            print(f"Line {i + 1}: {file2} has no more lines.")
            continue
        except ValueError:
            print(f"Line {i + 1}: Invalid number in {file2}.")
            continue

        if num1 == num2:
            print(f"Line {i + 1}: SAME ({num1})")
        else:
            print(f"Line {i + 1}: DIFFERENT ({num1} vs {num2})")

# Usage
compare_files('tb/router_test/files/f1.txt', 'tb/router_test/files/f2.txt')
