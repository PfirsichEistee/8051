public class UI_Register extends UI_Object {
	// ATTRIBUTES //
	private String txt;
	private UI_Button[] button;
	public boolean changed;
	
	
	// CONSTRUCTOR //
	public UI_Register(String pText, float px, float py, float ph) {
		super(px, py, ph * 8, ph);
		
		changed = false;
		txt = pText;
		button = new UI_Button[8];
		for (int i = 0; i < 8; i++) {
			button[i] = new UI_Button(i + "", true, ph * (7 - i), 0, ph, ph);
		}
		
		for (int i = (uiList.size() - 1); i >= 0; i--) {
			for (int k = 0; k < 8; k++) {
				if (uiList.get(i) == button[k]) {
					uiList.remove(i);
					break;
				}
			}
		}
	}
	
	// METHODS //
	public void drawObject() {
		translate(x, y);
		
		fill(255);
		textSize(25);
		text(txt, 0, 0);
		
		for (UI_Object obj : button) {
			obj.drawObject();
		}
		
		translate(-x, -y);
	}
	public void clickObject(float px, float py) {
		for (UI_Object obj : button) {
			if (px >= obj.x && px <= (obj.x + obj.w) &&
				py >= obj.y && py <= (obj.y + obj.h)) {
				obj.clickObject(px - x - obj.x, py - y - obj.y);
				changed = true;
				break;
			}
		}
	}
	public void dragObject(float px, float py, float dx, float dy) {
		
	}
	
	public boolean getState(int i) {
		return button[i].getState();
	}
	public void setState(int i, boolean state) {
		button[i].setState(state);
	}
	public int getValue() {
		changed = false;
		int v = 0;
		
		for (int i = 0; i < 8; i++) {
			if (getState(i)) {
				int p = 1;
				for (int k = 0; k < i; k++) {
					p *= 2;
				}
				v += p;
			}
		}
		
		return v;
	}
}