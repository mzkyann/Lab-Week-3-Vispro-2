import 'dart:async';
import 'dart:io';
import 'dart:math';

// Ukuran peta
const int width = 20;
const int height = 15;

// Definisikan bentuk cicak dengan tangan dan kaki
const List<String> cicakShape = [
  ' o ', // Bagian kepala
  'ooo', // Badan tengah
  'o o o', // Tangan dan kaki di samping
  'ooo', // Badan bawah
  ' o ' // Ekor
];
const String foodChar = 'X'; // Karakter untuk makanan
const String emptyChar = ' '; // Karakter untuk ruang kosong

// Arah gerakan cicak
enum Direction { up, down, left, right }

// Cicak terdiri dari beberapa titik (body)
List<Point<int>> cicakBody = [Point(10, 7)];
Point<int> food = getRandomFood();
Direction currentDirection = Direction.right;
bool gameOver = false;

// Fungsi untuk mendapatkan posisi makanan secara acak
Point<int> getRandomFood() {
  final random = Random();
  return Point(random.nextInt(width), random.nextInt(height));
}

// Fungsi untuk menggambar peta permainan
void drawGame() {
  // Bersihkan layar
  stdout.write('\x1B[2J\x1B[0;0H');

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      Point<int> currentPoint = Point(x, y);

      if (cicakBody.contains(currentPoint)) {
        // Cetak cicak dengan bentuk khusus di setiap bagian
        int index = cicakBody.indexOf(currentPoint) % cicakShape.length;
        stdout.write(cicakShape[index]);
      } else if (food == currentPoint) {
        stdout.write(foodChar);
      } else {
        stdout.write(emptyChar);
      }
    }
    stdout.writeln();
  }
}

// Fungsi untuk memperbarui posisi cicak
void update() {
  // Posisi kepala baru berdasarkan arah saat ini
  Point<int> newHead = Point(cicakBody.first.x, cicakBody.first.y);

  // Tentukan arah cicak menuju makanan
  if (food.y < cicakBody.first.y) {
    currentDirection = Direction.up;
  } else if (food.y > cicakBody.first.y) {
    currentDirection = Direction.down;
  } else if (food.x < cicakBody.first.x) {
    currentDirection = Direction.left;
  } else if (food.x > cicakBody.first.x) {
    currentDirection = Direction.right;
  }

  // Perbarui posisi baru berdasarkan arah
  switch (currentDirection) {
    case Direction.up:
      newHead = Point(newHead.x, newHead.y - 1);
      break;
    case Direction.down:
      newHead = Point(newHead.x, newHead.y + 1);
      break;
    case Direction.left:
      newHead = Point(newHead.x - 1, newHead.y);
      break;
    case Direction.right:
      newHead = Point(newHead.x + 1, newHead.y);
      break;
  }

  // Periksa tabrakan dengan dinding
  if (newHead.x < 0 ||
      newHead.x >= width ||
      newHead.y < 0 ||
      newHead.y >= height) {
    gameOver = true;
    return;
  }

  // Periksa tabrakan dengan tubuh cicak sendiri
  if (cicakBody.skip(1).contains(newHead)) {
    gameOver = true;
    return;
  }

  // Periksa jika cicak memakan makanan
  if (newHead == food) {
    cicakBody.insert(0, newHead); // Panjang cicak bertambah
    food = getRandomFood(); // Generate makanan baru
  } else {
    // Pindahkan cicak (kepala baru ditambah, ekor dihapus)
    cicakBody.insert(0, newHead);
    cicakBody.removeLast();
  }
}

// Fungsi untuk memulai game loop
void startGame() {
  Timer.periodic(Duration(milliseconds: 200), (timer) {
    if (gameOver) {
      timer.cancel();
      print('Game Over!');
      exit(0);
    }
    update();
    drawGame();
  });
}

void main() {
  print('Game Cicak dimulai!');

  // Mulai game loop
  startGame();
}
