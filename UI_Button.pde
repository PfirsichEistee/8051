public class UI_Button extends UI_Object {
	// ATTRIBUTES //
	private boolean state;
	private String txt;
	private boolean toggle; // if not toggle, then state will stay true until getState()
	
	private float anim;
	
	
	// CONSTRUCTOR //
	public UI_Button(String pText, boolean pToggle, float px, float py, float pw, float ph) {
		super(px, py, pw, ph);
		
		txt = pText;
		toggle = pToggle;
		state = false;
		anim = 0;
	}
	
	// METHODS //
	public void drawObject() {
		translate(x, y);
		
		if (state)
			anim += 0.1f;
		else
			anim -= 0.1f;
		
		anim = (anim < 0 ? 0 : anim);
		anim = (anim > 1 ? 1 : anim);
		
		fill(255);
		if (!enabled) fill(0);
		rect(0, 0, w, h);
		if (anim > 0) {
			fill(0, 255, 0, 100 * anim);
			if (!enabled) fill(255, 0, 0, 255 * anim);
			rect(2, 2, w - 4, h - 4);
		}
		
		fill(0);
		textSize(25);
		text(txt, 0, h - ((h - 25) / 2));
		
		translate(-x, -y);
	}
	public void clickObject(float px, float py) {
		if (!enabled) return;
		
		if (toggle) {
			state = !state;
		} else {
			state = true;
			anim = 1;
		}
	}
	public void dragObject(float px, float py, float dx, float dy) {
		
	}
	
	public String getText() {
		return txt;
	}
	
	public boolean getState() {
		if (toggle) {
			return state;
		} else {
			if (state == true) {
				state = false;
				return true;
			}
			return false;
		}
	}
	public void setState(boolean p) {
		state = p;
	}
}