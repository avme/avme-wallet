// Copyright (c) 2020-2021 AVME Developers
// Distributed under the MIT/X11 software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#include "main-gui.h"
#include <hidapi/hidapi.h>

// Implementation of AVME Wallet as a GUI (Qt) program.

int main(int argc, char *argv[]) {
  // Get the system's DPI scale using a dummy temp QApplication
  int res;
  std::vector<unsigned char> bufferVector;
	unsigned char buf[65];
	#define MAX_STR 255
	wchar_t wstr[MAX_STR];
	hid_device *handle;
	int i;

	struct hid_device_info *devs, *cur_dev;

	if (hid_init())
		return -1;
//  {0x2c97, 0x0001, 0, 0xffa0}, 
// VID PID - 
  unsigned short ledgerVID = 0;
  unsigned short ledgerPID = 0;
	devs = hid_enumerate(0x0, 0x0);
	cur_dev = devs;
	while (cur_dev) {
		printf("Device Found\n  type: %04hx %04hx\n  path: %s\n  serial_number: %ls", cur_dev->vendor_id, cur_dev->product_id, cur_dev->path, cur_dev->serial_number);
		printf("\n");
		printf("  Manufacturer: %ls\n", cur_dev->manufacturer_string);
		printf("  Product:      %ls\n", cur_dev->product_string);
		printf("  Release:      %hx\n", cur_dev->release_number);
		printf("  Interface:    %d\n",  cur_dev->interface_number);
		printf("  Usage (page): 0x%hx (0x%hx)\n", cur_dev->usage, cur_dev->usage_page);
		printf("\n");
		cur_dev = cur_dev->next;
	}
	hid_free_enumeration(devs);
  
  memset(buf,0x00,sizeof(buf));
  buf[1] = 0x01;
  buf[2] = 0x01;
  buf[3] = 0x05;
  buf[4] = 0x00;
  buf[5] = 0x00; 
  buf[6] = 0x00; 
  buf[7] = 0x12; 
  buf[8] = 0xE0; 
  buf[9] = 0x02; 
  buf[10] = 0x00; 
  buf[11] = 0x01; 
  buf[12] = 0x0D; 
  buf[13] = 0x03; 
  buf[14] = 0x80; 
  buf[15] = 0x00; 
  buf[16] = 0x00;
  buf[17] = 0x2C; 
  buf[18] = 0x80; 
  buf[19] = 0x00; 
  buf[20] = 0x00; 
  buf[21] = 0x3C; 
  buf[22] = 0x80;

  
  handle = hid_open(0x2c97, 0x1015, NULL);
  if (!handle) {
		printf("unable to open device\n");
 		return 1;
	}
  
  wstr[0] = 0x0000;
	res = hid_get_manufacturer_string(handle, wstr, MAX_STR);
	if (res < 0)
		printf("Unable to read manufacturer string\n");
	printf("Manufacturer String: %ls\n", wstr);

	// Read the Product String
	wstr[0] = 0x0000;
	res = hid_get_product_string(handle, wstr, MAX_STR);
	if (res < 0)
		printf("Unable to read product string\n");
	printf("Product String: %ls\n", wstr);
  
	res = hid_write(handle, buf, 65);
	if (res < 0) {
		printf("Unable to write()\n");
		printf("Error: %ls\n", hid_error(handle));
	}
  
  memset(buf,0x00,sizeof(buf));
  
	res = 0;
	// Get first answer...
	res = hid_read(handle, buf, sizeof(buf));
  
  for (auto uc : buf)
    bufferVector.push_back(uc);
  // If it is there something more to read, do it
  for (;;) {
    memset(buf,0x00,sizeof(buf));
    res = hid_read_timeout(handle, buf, sizeof(buf), 1500);
    if (res == 0)
      break;
    
    for (auto uc : buf)
      bufferVector.push_back(uc);
    
  }
  
	printf("Data read:\n   ");
	// Print out the returned buffer.
	for (i = 0; i < bufferVector.size(); i++)
		printf("%02hhx ", bufferVector[i]);
	printf("\n");

	hid_close(handle);

	/* Free static HIDAPI objects. */
	hid_exit();
	
  // Override
  return 0;
  QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QApplication* temp = new QApplication(argc, argv);
  double scaleFactor = temp->screens()[0]->logicalDotsPerInch() / 96.0;
  delete temp;
  qputenv("QT_SCALE_FACTOR", QByteArray::number(scaleFactor));

  // Create the actual application and register our custom class into it
  QApplication app(argc, argv);
  QQmlApplicationEngine engine;
  System sys;
  engine.rootContext()->setContextProperty("System", &sys);

  // Set the app's text font and icon
  QFontDatabase::addApplicationFont(":/fonts/RobotoMono-Bold.ttf");
  QFontDatabase::addApplicationFont(":/fonts/RobotoMono-Italic.ttf");
  QFontDatabase::addApplicationFont(":/fonts/RobotoMono-Regular.ttf");
  QFont font("Roboto Mono");
  font.setStyleHint(QFont::Monospace);
  QApplication::setFont(font);
  app.setWindowIcon(QIcon(":/img/avme_logo.png"));

  // Load the main screen and start the app
  engine.load(QUrl(QStringLiteral("qrc:/qml/screens/main.qml")));
  if (engine.rootObjects().isEmpty()) return -1;
  return app.exec();
}

