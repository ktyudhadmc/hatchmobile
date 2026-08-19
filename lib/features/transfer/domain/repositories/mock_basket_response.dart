/// Mock response untuk endpoint getBasketByCode
/// Dipakai untuk testing repository/usecase tanpa perlu hit API sungguhan.
const Map<String, dynamic> mockBasketResponseJson = {
  "status": true,
  "message": "Berhasil mengambil data basket",
  "data": {
    "id": 1,
    "basket_code": "A0001",
    "grades": [
      {
        "id": 1,
        "grade": "A",
        "quantity": 1000,
        "received_quantity": 1000,
      },
      {
        "id": 2,
        "grade": "B",
        "quantity": 250,
        "received_quantity": 1000,
      },
    ],
    "transfer": {
      "id": 1,
      "transfer_code": "15082024TE0002",
      "transfer_date": "2024-01-15",
      "branch": {
        "id": 1,
        "name": "Jabung",
      },
    },
  },
};

/// Contoh mock untuk kasus basket tidak ditemukan (404 / error)
const Map<String, dynamic> mockBasketNotFoundResponseJson = {
  "status": false,
  "message": "Basket dengan kode tersebut tidak ditemukan",
  "data": null,
};

/// Contoh mock untuk kasus basket sudah pernah diterima sebelumnya
/// (berguna untuk testing validasi duplicate scan)
const Map<String, dynamic> mockBasketAlreadyReceivedResponseJson = {
  "status": false,
  "message": "Basket ini sudah pernah diterima sebelumnya",
  "data": {
    "id": 1,
    "basket_code": "A0001",
    "grades": [
      {
        "id": 1,
        "grade": "A",
        "quantity": 1000,
        "received_quantity": 1000,
      },
    ],
    "transfer": {
      "id": 1,
      "transfer_code": "15082024TE0002",
      "transfer_date": "2024-01-15",
      "branch": {
        "id": 1,
        "name": "Jabung",
      },
    },
  },
};