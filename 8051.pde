
public ArrayList<UI_Object> uiList;

Nano nano;
UI_List tabView;

UI_Window simulationTab;
UI_Window portTab;
UI_Window saveTab;
UI_Window ledTab;
UI_Window floatingWindow;

MicroController controller;


// Touch
int mouseDownX = -999;
int mouseDownY = -999;
boolean mouseDrag = false;

int viewScroll = 0;


// Emulator
boolean active = false;
float updatesPerFrame = 0.7f;
float updateCounter = 0;


// Else



void setup() {
	size(1024, 650);
	
	uiList = new ArrayList<UI_Object>();
	
	nano = new Nano();
	nano.txt = "";
	
	tabView = new UI_List(width - 200, 0, 200, height);
	tabView.setClip(false);
	tabView.insert("Nano");
	tabView.insert("Simulation");
	tabView.insert("P-Data View");
	tabView.insert("Data View");
	tabView.insert("SFR View");
	tabView.insert("Port View");
	tabView.insert("LED View");
	tabView.insert("Saved Files");
	tabView.setSelectedIndex(0);
	
	createTabs();
	
	floatingWindow = new UI_Window(300, 300, 200, 150);
	floatingWindow.dragable = true;
	floatingWindow.addChild(new UI_Button("Run", false,
		5, 5, (200 - 15) / 2, (150 - 15) / 2));
	floatingWindow.addChild(new UI_Button("Stop", false,
		10 + ((200 - 15) / 2), 5, (200 - 15) / 2, (150 - 15) / 2));
	floatingWindow.addChild(new UI_Button("Step", false,
		5, 10 + ((150 - 15) / 2), (200 - 15) / 2, (150 - 15) / 2));
	floatingWindow.addChild(new UI_Button("Reset", false,
		10 + ((200 - 15) / 2), 10 + ((150 - 15) / 2), (200 - 15) / 2, (150 - 15) / 2));
	
	
	controller = new MicroController();
}


void draw() {
	mouseUpdate();
	
	for (int i = 0; i < uiList.size(); i++)
		uiList.get(i).enabled = false;
	tabView.enabled = true;
	
	background(0);
	switch (tabView.getSelectedIndex()) {
		case(0):
			nano.drawNano();
			break;
		case(1):
			simulationTab.enabled = true;
			break;
		case(2):
			drawProgramDataView();
			break;
		case(3):
			drawRamDataView();
			break;
		case(4):
			drawRamSfrView();
			break;
		case(5):
			portTab.enabled = true;
			break;
		case(6):
			ledTab.enabled = true;
			break;
		case(7):
			saveTab.enabled = true;
			break;
		default:
			fill(255);
			textSize(40);
			textLeading(40);
			text("No tab selected.", 0, 40);
			break;
	}
	
	if (simulationTab.getButtonState("Floating Window"))
		floatingWindow.enabled = true;
	
	for (int i = 0; i < uiList.size(); i++)
		if (uiList.get(i).enabled) uiList.get(i).drawObject();
	
	
	updateSimulation();
	//text("" + millis(), 50, 100);
	
	// Emulator
	if (active) {
		updateCounter += updatesPerFrame;
		while (updateCounter >= 1) {
			updateCounter -= 1;
			controller.exec();
		}
	}
	
	// Update Port-UI
	for (int i = 0; i < 6; i++) {
		UI_Register reg = portTab.children.get(i);
		boolean changed = reg.changed;
		if (reg.getValue() != controller.getSfr(0x80 + 0x10 * i)) {
			if (changed) {
				controller.setSfr(0x80 + 0x10 * i, reg.getValue());
			} else {
				String strVal = binary(controller.getSfr(0x80 + 0x10 * i), 8);
				for (int k = 7; k >= 0; k--) {
					reg.setState(7 - k, (strVal[k] == "1" ? true : false));
				}
			}
		}
	}
	
	// Update LED UI
	if (ledTab.enabled) {
		for (int i = 0; i < 7; i++) {
			int ph = 0b00000001 << i;
			if ((controller.ramSfr[0xA0 - 0x80] & ph) != 0) {
				ledTab.children.get(i).setState(true);
			} else {
				ledTab.children.get(i).setState(false);
			}
		}
	}
}


void keyPressed() {
	switch (tabView.getSelectedIndex()) {
		case(0):
			nano.nanoKeyPressed(str(key), keyCode);
			break;
	}
}


void mousePressed() {
	mouseDrag = false;
	mouseDownX = mouseX;
	mouseDownY = mouseY;
}
int mouseLastMillis = 0;
void mouseReleased() {
	if ((millis() - mouseLastMillis) < 50) return;
	else mouseLastMillis = millis();
	
	if (!mouseDrag) {
		// Click
		UI_Object obj = getUI_ObjectFromMouse();
		
		if (obj != null)
			obj.clickObject(mouseX - obj.x, mouseY - obj.y);
		
		if (obj == tabView)
			viewScroll = 0;
	}
}
void mouseUpdate() {
	if (mousePressed && !mouseDrag) {
		int dx = mouseX - mouseDownX;
		int dy = mouseY - mouseDownY;
		
		if (sqrt(dx * dx + dy * dy) > 25) {
			mouseDrag = true;
		}
	} else if (mousePressed && mouseDrag) {
		// Drag
		int dx = mouseX - mouseDownX;
		int dy = mouseY - mouseDownY;
		mouseDownX = mouseX;
		mouseDownY = mouseY;
		
		
		UI_Object obj = getUI_ObjectFromMouse();
		
		if (obj != null)
			obj.dragObject(mouseX - obj.x, mouseY - obj.y, dx, dy);
		else
			viewScroll += dy;
	}
}


UI_Object getUI_ObjectFromMouse() {
	for (int i = (uiList.size() - 1); i >= 0; i--) {
		UI_Object obj = uiList.get(i);
		if (obj.enabled && mouseX >= obj.x && mouseX <= (obj.x + obj.w) &&
			mouseY >= obj.y && mouseY <= (obj.y + obj.h)) {
			return obj;
		}
	}
	return null;
}


void createTabs() {
	simulationTab = new UI_Window(10, 10, width - 220, height - 20);
	simulationTab.addChild(new UI_Button("Run", false, 5, 5,
		250, 50));
	simulationTab.addChild(new UI_Button("Stop", false, 260, 5,
		250, 50));
	simulationTab.addChild(new UI_Button("Floating Window", true, 520, 5,
		250, 50));
	
	simulationTab.addChild(new UI_Button("Recompile", false, 5, 100,
		250, 50));
	
	// Port
	int w = width - 220;
	int h = height - 20;
	portTab = new UI_Window(10, 10, w, h);
	int btnH = ((w - 15) / 2) / 8;
	portTab.addChild(new UI_Register("P0", 5, 25, btnH));
	portTab.addChild(new UI_Register("P1", 10 + (btnH * 8), 25, btnH));
	portTab.addChild(new UI_Register("P2", 5, 50 + btnH, btnH));
	portTab.addChild(new UI_Register("P3", 10 + (btnH * 8), 50 + btnH, btnH));
	portTab.addChild(new UI_Register("P4", 5, 75 + btnH * 2, btnH));
	portTab.addChild(new UI_Register("P5", 10 + (btnH * 8), 75 + btnH * 2, btnH));
	
	// LED
	ledTab = new UI_Window(10, 10, width - 220, height - 20);
	ledTab.addChild(new UI_Button("A0h.0", false, 60, 5, 100, 50));
	ledTab.addChild(new UI_Button("A0h.1", false, 5, 60, 50, 100));
	ledTab.addChild(new UI_Button("A0h.2", false, 165, 60, 50, 100));
	ledTab.addChild(new UI_Button("A0h.3", false, 60, 165, 100, 50));
	ledTab.addChild(new UI_Button("A0h.4", false, 5, 220, 50, 100));
	ledTab.addChild(new UI_Button("A0h.5", false, 165, 220, 50, 100));
	ledTab.addChild(new UI_Button("A0h.6", false, 60, 325, 100, 50));
	for (UI_Button btn : ledTab.children) {
		btn.enabled = false;
	}
	
	
	
	// Save
	saveTab = new UI_Window(10, 10, width - 220, height - 20);
	
	for (int i = 0; i < 8; i++) {
		saveTab.addChild(new UI_Button("Save Slot " + (i + 1), false, 5, 5 + 60 * i,
			250, 50));
		saveTab.addChild(new UI_Button("Load Slot " + (i + 1), false, 260, 5 + 60 * i,
			250, 50));
	}
}


void drawProgramDataView() {
	translate(0, viewScroll);
	
	textSize(15);
	
	for (int i = 0; i < controller.programData.length; i++) {
		int yy = floor(i / 8);
		
		if (((yy * 20) + viewScroll + 20) < 0) continue;
		if (((yy * 20) + viewScroll) > height) break;
		
		int xx = i % 8;
		String h = hex(controller.programData[i], 2);
		//h = h[6] + h[7];
		fill(255);
		text(h, 150 + xx * 50, (yy + 1) * 20);
		
		if (xx == 0) {
			text(hex(i), 10, (yy + 1) * 20);
		}
		
		
		if (i == controller.PC) {
			fill(255, 0, 0, 100);
			rect(150 + xx * 50, yy * 20, 30, 20);
		}
	}
	
	String info = "PC = " + hex(controller.PC, 4) + "\nDPTR = " 
		+ hex(controller.DPTR, 4) + "\nSP = " + hex(controller.SP, 4)
		+ "\nA = " + hex(controller.A, 2);
	text(info, width - 350, 20);
	
	translate(0, -viewScroll);
}

void drawRamDataView() {
	translate(0, viewScroll);
	
	textSize(15);
	fill(255);
	
	for (int i = 0; i < controller.ramData.length; i++) {
		int yy = floor(i / 8);
		
		if (((yy * 20) + viewScroll + 20) < 0) continue;
		if (((yy * 20) + viewScroll) > height) break;
		
		int xx = i % 8;
		String h = hex(controller.ramData[i], 2);
		//h = h[6] + h[7];
		
		text(h, 150 + xx * 50, (yy + 1) * 20);
		
		if (xx == 0) {
			text(hex(i), 10, (yy + 1) * 20);
		}
	}
	
	translate(0, -viewScroll);
}


void drawRamSfrView() {
	translate(0, viewScroll);
	
	textSize(15);
	
	fill(255);
	for (int i = 0; i < controller.ramSfr.length; i++) {
		int yy = floor(i / 8);
		
		if (((yy * 20) + viewScroll + 20) < 0) continue;
		if (((yy * 20) + viewScroll) > height) break;
		
		int xx = i % 8;
		String h = hex(controller.ramSfr[i], 2);
		//h = h[6] + h[7];
		
		text(h, 150 + xx * 50, (yy + 1) * 20);
		
		if (xx == 0) {
			text(hex(i + 0x80), 10, (yy + 1) * 20);
		}
	}
	
	translate(0, -viewScroll);
}


void updateSimulation() {
	boolean runState = simulationTab.getButtonState("Run");
	boolean stopState = simulationTab.getButtonState("Stop");
	boolean fWindowState = simulationTab.getButtonState("Floating Window");
	boolean recompileState = simulationTab.getButtonState("Recompile");
	
	if (runState)
		active = true;
	if (stopState)
		active = false;
	
	if (recompileState) {
		Compiler compiler = new Compiler(nano.txt);
		compiler.compile();
		compiler.overwriteController(controller);
	}
	
	for (int i = 1; i <= 8; i++) {
		boolean save = saveTab.getButtonState("Save Slot " + i);
		boolean load = saveTab.getButtonState("Load Slot " + i);
		
		if (save) saveSlot(i);
		else if (load) loadSlot(i);
	}
	
	// Floating Window
	boolean fwRun = floatingWindow.getButtonState("Run");
	boolean fwStop = floatingWindow.getButtonState("Stop");
	boolean fwStep = floatingWindow.getButtonState("Step");
	boolean fwReset = floatingWindow.getButtonState("Reset");
	
	if (fwRun)
		active = true;
	else if (fwStop)
		active = false;
	
	if (fwStep)
		controller.exec();
	
	if (fwReset) {
		controller.PC = 0;
		controller.A = 0;
		controller.DPTR = 0;
		controller.SP = 0x07;
		
		for (int i = 0; i < controller.ramData.length; i++)
			controller.ramData[i] = 0;
		for (int i = 0; i < controller.ramSfr.length; i++)
			controller.ramSfr[i] = 0;
	}
}


void saveSlot(int slot) {
	saveStrings("8051-slot-" + slot, { nano.txt });
	println("SAVED TO SLOT " + slot + ". TIMESTAMP: " + millis());
}

void loadSlot(int slot) {
	String[] lines;
	String str = "";
	try {
		String[] lines = loadStrings("8051-slot-" + slot);
		
		if (lines.length > 0) {
			for (int i = 0; i < lines.length; i++) {
				str += lines[i];
				if ((i + 1) != lines.length) str += "\n";
			}
		}
	} catch (Exception e) {
		// Slot unoccupied
	}
	
	nano.txt = str;
	nano.sel = -1;
	nano.selRow = 0;
	println("LOADED SLOT " + slot + ". TIMESTAMP: " + millis());
}
