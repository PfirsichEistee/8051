public abstract class UI_Object {
	// ATTRIBUTES //
	public float x, y;
	public float w, h;
	public boolean enabled;
	
	
	// CONSTRUCTOR //
	public UI_Object(float px, float py, float pw, float ph) {
		x = px;
		y = py;
		w = pw;
		h = ph;
		enabled = true;
		
		uiList.add(this);
	}
	
	
	// METHODS //
	public abstract void drawObject();
	public abstract void clickObject(float px, float py);
	public abstract void dragObject(float px, float py, float dx, float dy);
}