import os

folder = r'C:\Users\budi.kusharyanto\OneDrive\WS Dokumen'
files = sorted([f for f in os.listdir(folder) if f.startswith('diagram_gambar_') and f.endswith('.png')])

print("Existing diagram files:")
print("-" * 50)
for f in files:
    size_kb = os.path.getsize(os.path.join(folder, f)) / 1024
    print(f"{f} - {size_kb:.1f} KB")
print("-" * 50)
print(f"Total: {len(files)} PNG files")