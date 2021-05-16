public class UI_Window extends UI_Object {
	// ATTRIBUTES //
	public ArrayList<UI_Object> children;
	public boolean dragable;
	
	
	// CONSTRUCTOR //
	public UI_Window(float px, float py, float pw, float ph) {
		super(px, py, pw, ph);
		
		children = new ArrayList<UI_Object>();
		dragable = false;
	}
	
	// METHODS //
	public void drawObject() {
		translate(x, y);
		
		stroke(100, 100, 100, 255);
		fill(100, 100, 100, 150);
		
		rect(0, 0, w, h);
		
		for (UI_Object obj : children) obj.drawObject();
		
		translate(-x, -y);
	}
	public void clickObject(float px, float py) {
		for (UI_Object obj : children) {
			if (px >= obj.x && px <= (obj.x + obj.w) &&
				py >= obj.y && py <= (obj.y + obj.h)) {
				obj.clickObject(px - x - obj.x, py - y - obj.y);
				break;
			}
		}
	}
	public void dragObject(float px, float py, float dx, float dy) {
		if (dragable) {
			x += dx;
			y += dy;
		}
	}
	
	
	public void addChild(UI_Object obj) {
		for (int i = 0; i < uiList.size(); i++) {
			if (uiList.get(i) == obj) {
				uiList.remove(i);
				children.add(obj);
				break;
			}
		}
	}
	
	public boolean getButtonState(String txt) {
		for (UI_Object obj : children)
			if (obj.getText().equals(txt)) return obj.getState();
		
		return false;
	}
}
