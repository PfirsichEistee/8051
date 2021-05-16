public class Nano {
	// ATTRIBUTES //
	String txt = "> Nano Text Editor! <";
	
	// Selection
	int selRow = 0;
	int sel = -1; // char (-1 is the very end)
	
	// Editor stuff
	int scroll = 0;
	boolean showCursor = true;
	int cursorCounter = 0;
	
	private int[] disallowedKeyCodes = { 16, 17, 18, 157, 37, 38, 39, 40, 8, 20 };
	
	
	// CONSTRUCTOR //
	public Nano() {
		// ...
	}
	
	
	// METHODS //
	public void drawNano() {
		translate(0, -scroll);
		
		textSize(25);
		textLeading(25);
		
		background(0);
		fill(255);
		stroke(255);
		
		text(txt, 0, 25);
		
		if (!showCursor) fill(0, 0, 0, 0);
		if (sel != -1) {
			rect(textWidth(substring(getRow(selRow), 0, sel - 1)), selRow * 25, 12, 25);
		} else {
			rect(getRowWidth(selRow), selRow * 25, 12, 25);
		}
		
		
		cursorCounter++;
		if (cursorCounter >= 10) {
			cursorCounter = 0;
			showCursor = !showCursor;
		}
		
		
		translate(0, scroll);
	}
	
	public void nanoKeyPressed(String key, int keyCode) {
		if (keyCode == 37) {
			if (sel == -1) sel = getRow(selRow).length - 1;
			else if (sel > 0) sel--;
			else if (sel == 0 && selRow > 0) {
				sel = -1;
				selRow--;
			}
		} else if (keyCode == 39) {
			if (sel != -1) {
				sel++;
				if (sel >= getRow(selRow).length) sel = -1;
			} else if (sel == -1 && (selRow + 1) < getRows()) {
				selRow++;
				sel = 0;
			}
		} else if (keyCode == 38) {
			selRow--;
			if (selRow < 0) selRow = 0;
			
			if (sel != -1 && sel >= getRow(selRow).length) {
				//sel = getRow(selRow).length - 1;
				sel = -1;
			}
		} else if (keyCode == 40) {
			selRow++;
			if (selRow < 0) selRow = 0;
			else if (getRowStart(selRow) == -1) selRow--;
			
			if (sel != -1 && sel >= getRow(selRow).length) {
				//sel = getRow(selRow).length - 1;
				sel = -1;
			}
		} else if (keyCode == 8) {
			int selChar = getSelectedChar();
			
			if (selChar != 0) {
				if (selChar != -1) {
					if (txt[selChar - 1] == "\n") {
						selRow--;
						sel = getRow(selRow).length;
					} else if (sel != -1) {
						sel--;
					}
					
					txt = substring(txt, 0, selChar - 2) + substring(txt, selChar, txt.length - 1);
				} else {
					if (txt[txt.length - 1] == "\n") {
						selRow--;
						sel = -1;
					}
					
					txt = substring(txt, 0, txt.length - 2);
				}
			}
		}
		
		
		for (int i = 0; i < disallowedKeyCodes.length; i++) {
			if (keyCode == disallowedKeyCodes[i]) {
				updateScroll();
				return;
			}
		}
		
		if (keyCode == 10) key = "\n";
		
		int selChar = getSelectedChar();
		if (selChar == -1) {
			txt += key;
		} else {
			if (selChar != 0) {
				txt = substring(txt, 0, selChar - 1) + key +
					substring(txt, selChar, txt.length - 1);
				
				//if (sel != -1) sel++;
			} else {
				txt = str(key) + txt;
				//sel++;
			}
		}
		
		if (keyCode != 10) {
			if (sel != -1) sel++;
		} else {
			// Copy spaces
			int count = 0;
			String rstr = getRow(selRow);
			for (int i = 0; i < rstr.length; i++) {
				if (rstr[i] == " ") {
					count++;
				} else {
					break;
				}
			}
			rstr = "";
			for (int i = 0; i < count; i++) rstr += " ";
			int rowStart = getRowStart(selRow + 1);
			txt = substring(txt, 0, rowStart - 1) + rstr + substring(txt, rowStart, txt.length - 1);
			//println("" + count + " spaces");
			
			
			selRow++;
			sel = count;
			if (selChar == -1) sel = -1;
		}
		
		updateScroll();
	}
	
	public String getRow(int row) {
		int l = getRowStart(row);
		int r = getRowEnd(row);
		
		if (txt[l] == "\n") return "";
		
		if (l != r && r != -1) r--;
		return subtxt(l, r);
	}
	
	
	private float getRowWidth(int row) {
		return textWidth(getRow(row));
	}
	
	private String subtxt(int l, int r) {
		String str = "";
		if (r == -1) r = txt.length - 1;
		if (r < l) return str;
		
		for (int i = l; i <= r; i++) {
			str += txt[i];
		}
		
		return str;
	}
	
	private String substring(String substr, int l, int r) {
		String str = "";
		
		if (r < l) return str;
		
		for (int i = l; i <= r; i++) {
			str += substr[i];
		}
		
		return str;
	}
	
	private int getRowStart(int row) {
		int index = -1;
		int phRow = 0;
		
		for (int i = 0; i < txt.length; i++) {
			if (phRow == row) break;
			
			if (txt[i] == "\n") {
				index = i;
				phRow++;
			}
		}
		
		if (phRow != row) index = -2; // Dont let this happen!
		
		return index + 1;
	}
	
	private int getRowEnd(int row) {
		int index = -1;
		int phRow = -1;
		
		for (int i = 0; i < txt.length; i++) {
			if (txt[i] == "\n") {
				index = i;
				phRow++;
			} else if (i == (txt.length - 1)) {
				index = -1;
				phRow++;
			}
			
			if (phRow == row) break;
		}
		
		if (phRow == -1) phRow = 0;
		if (phRow != row) index = -1; // Dont let this happen!
		
		return index;
	}
	
	
	private int getSelectedChar() {
		if (sel != -1) {
			return getRowStart(selRow) + sel;
		} else {
			return getRowEnd(selRow);
		}
	}
	
	private void updateScroll() {
		while ((selRow * 25 - scroll) < 0) scroll -= 25;
		while ((selRow * 25 + 25 - scroll) > height) scroll += 25;
	}
	
	
	public int getRows() {
		int r = 1;
		for (int i = 0; i < txt.length; i++) {
			if (txt[i] == "\n") {
				r++;
			}
		}
		
		return r;
	}
	
	public void saveData() {
		saveStrings("nanoData.txt", { txt });
		println("Data saved.");
	}
	
	public void loadData() {
		txt = "";
		String[] loaded = loadStrings("nanoData.txt");
		for (int i = 0; i < loaded.length; i++)
			txt += loaded[i];
		
		println("Data loaded.");
	}
}
