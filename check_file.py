import sys

path = r"c:\Users\Administrator\Desktop\Tapzy App\tapzy_2 - Copy\lib\screens\dashboard_screens\my_card_screen.dart"
with open(path, "r", encoding="utf-8") as f:
    lines = f.readlines()

print("--- Lines 825 to 845 ---")
for idx in range(824, min(845, len(lines))):
    print(f"{idx+1}: {repr(lines[idx])}")
