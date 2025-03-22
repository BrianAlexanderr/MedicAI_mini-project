import os
import psycopg2

# 1️⃣ Koneksi ke Database PostgreSQL
conn = psycopg2.connect(
    host="localhost",
    database="medicai_database",
    user="postgres",
    password="bryanalexander"
)
cursor = conn.cursor()

# 2️⃣ Folder yang Berisi Gambar Rumah Sakit
image_folder = "./New folder/"  # 🔹 Ganti dengan path folder Anda

# 3️⃣ Data Rumah Sakit (Tanpa Nama Gambar)
hospitals = [
    ("RS Proklamasi BSD", "Hospital", -6.302, 106.666, "Jalan Pahlawan Seribu No.7, Lengkong Gudang, Serpong, Tangerang Selatan, Banten 15321"),
    ("RS Rumah Indonesia Sehat", "Hospital", -6.295, 106.678, "Jalan Lengkong Gudang Timur No.77, Lengkong Gudang Timur, Serpong, Tangerang Selatan, Banten 15310"),
    ("RS Sari Asih Ciputat", "Hospital", -6.292, 106.765, "Jalan Sasak Tinggi No.3, Ciputat, Tangerang Selatan, Banten 15411"),
    ("Bethsaida Hospital", "Hospital", -6.243, 106.626, "Jalan Boulevard Raya Gading Serpong, Tangerang, Banten"),
    ("RS Hermina Periuk Tangerang", "Hospital", -6.194, 106.647, "Jalan Raya Periuk No.50, Periuk, Tangerang, Banten"),
    ("RSIA Bunda Ciputat", "Hospital", -6.293, 106.762, "Jalan RE Martadinata No.30, Ciputat, Tangerang Selatan, Banten"),
    ("Siloam Hospitals Lippo Village", "Hospital", -6.224, 106.618, "Jalan Siloam No.6, Lippo Village, Tangerang, Banten"),
    ("RS EMC Alam Sutera", "Hospital", -6.240, 106.652, "Jalan Alam Sutera Boulevard No.25, Serpong Utara, Tangerang Selatan, Banten"),
    ("RS Medika BSD", "Hospital", -6.302, 106.666, "Jalan BSD Serpong Kavling Komplek 3A, Serpong, Tangerang Selatan, Banten"),
    ("RS Bhineka Bakti Husada", "Hospital", -6.342, 106.765, "Jalan Pondok Cabe Raya No.17, Pamulang, Tangerang Selatan, Banten"),
    ("RSU Tangerang Selatan", "Hospital", -6.342, 106.754, "Jalan Pajajaran No.101, Pamulang Barat, Tangerang Selatan, Banten"),
    ("RS IMC Bintaro", "Hospital", -6.276, 106.732, "Jalan Jombang Raya No.56, Bintaro, Tangerang Selatan, Banten"),
    ("RSIA Permata Sarana Husada", "Hospital", -6.342, 106.754, "Pamulang, Tangerang Selatan, Banten"),
    ("RS Umum Murni Asih", "Hospital", -6.236, 106.413, "Jalan Raya Serang KM 24 No.1, Talagasari, Balaraja, Tangerang, Banten 15610"),
    ("RS Ibu dan Anak Ilanur", "Hospital", -6.236, 106.413, "Jalan Raya Serang KM 24 No.1, Talagasari, Balaraja, Tangerang, Banten 15610"),
    ("RS UniMedika Sepatan", "Hospital", -6.118, 106.589, "Jalan Raya Pakuhaji No.3, Sepatan, Tangerang, Banten 15521"),
    ("RS Siloam Hospitals Kelapa Dua", "Hospital", -6.231, 106.570, "Jalan Kelapa Dua Raya No.1001, Kelapa Dua, Tangerang, Banten 15810"),
    ("Eka Hospital BSD", "Hospital", -6.302, 106.666, "Central Business District Lot IX, BSD City, Tangerang, Banten")
]

# 4️⃣ Proses Upload ke PostgreSQL
for hospital in hospitals:
    name, category, address, lat, lon = hospital
    
    # 🔹 Sesuaikan nama gambar (konversi ke huruf kapital dan format JPEG)
    image_name = name.upper() + ".jpeg"
    image_path = os.path.join(image_folder, image_name)

    # Cek apakah gambar tersedia
    if os.path.exists(image_path):
        with open(image_path, "rb") as file:
            image_data = file.read()
    else:
        print(f"❌ Gambar untuk '{name}' tidak ditemukan: {image_name}")
        continue  # Lewati jika gambar tidak ada

    # 🔹 Insert data ke PostgreSQL
    query = """
    INSERT INTO healthcarefacilities (name, type, latitude, longitude, address, photo)
    VALUES (%s, %s, %s, %s, %s, %s)
    """
    cursor.execute(query, (name, category, address, lat, lon, psycopg2.Binary(image_data)))

# 5️⃣ Commit & Tutup Koneksi
conn.commit()
cursor.close()
conn.close()

print("✅ Semua rumah sakit dan gambar berhasil disimpan ke database!")

