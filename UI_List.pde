public class UI_List extends UI_Object {
	// ATTRIBUTES //
	private ArrayList<String> item;
	private int selected;
	private int scroll;
	private boolean clip;
	
	
	// CONSTRUCTOR //
	public UI_List(float px, float py, float pw, float ph) {
		super(px, py, pw, ph);
		
		item = new ArrayList<String>();
		selected = -1;
		scroll = 0;
		clip = true;
	}
	
	// METHODS //
	public void drawObject() {
		translate(x, y);
		
		stroke(255, 100, 100, 255);
		fill(100, 100, 100, 150);
		
		rect(0, 0, w, h);
		
		textSize(40);
		textLeading(40);
		translate(0, scroll);
		for (int i = 0; i < item.size(); i++) {
			if (clip)
				if ((i * 40 + scroll) < 0 || ((i + 1) * 40 + scroll) > h) continue;
			
			fill(255);
			text(item.get(i), 0, (i + 1) * 40);
			
			if (selected == i) {
				fill(255, 100, 100, 75);
				rect(0, i * 40, w, 40);
			}
		}
		translate(0, -scroll);
		
		translate(-x, -y);
	}
	public void clickObject(float px, float py) {
		py -= scroll;
		selected = floor(py / 40);
		if (selected < 0 || selected >= item.size()) selected = -1;
	}
	public void dragObject(float px, float py, float dx, float dy) {
		scroll += dy;
		if (scroll > 0) scroll = 0;
		else if (-scroll > ((item.size() - 1) * 40)) scroll = -(item.size() - 1) * 40;
	}
	
	public void setClip(boolean pClip) {
		clip = pClip;
	}
	
	public void insert(String str) {
		item.add(str);
	}
	public String getSelectedText() {
		return (selected != -1 ? item.get(selected) : "-None-");
	}
	public int getSelectedIndex() {
		return selected;
	}
	public void setSelectedIndex(int p) {
		selected = p;
	}
}
