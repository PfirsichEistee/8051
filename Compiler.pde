public class Compiler {
	// ATTRIBUTES //
	private String[] lines;
	private int row;
	
	private ArrayList<String> compiledLines;
	
	private ArrayList<String> aliasName;
	private ArrayList<Integer> aliasAddress;
	
	
	private boolean error;
	
	
	private final int TYPE_CMD = 0;
	private final int TYPE_CONSTANT = 1;
	private final int TYPE_ADDRESS = 2;
	private final int TYPE_REGISTER = 3;
	private final int TYPE_AT_REGISTER = 4;
	private final int TYPE_AKKU = 5;
	private final int TYPE_BITADDRESS = 6;
	private final int TYPE_DPTR = 7;
	
	
	// CONSTRUCTOR //
	public Compiler(String pTxt) {
		lines = splitTokens(pTxt, "\n");
		row = 0;
		compiledLines = new ArrayList<String>();
		aliasName = new ArrayList<String>();
		aliasAddress = new ArrayList<Integer>();
		
		error = false;
		
		// Format text
		for (int i = (lines.length - 1); i >= 0; i--) {
			if (lines[i].length != 0) {
				// Remove Comments
				for (int k = 0; k < lines[i].length; k++) {
					if (lines[i][k] == ";") {
						if (k == 0) {
							lines[i] = "";
						} else {
							lines[i] = lines[i].substring(0, k);
						}
						break;
					}
				}
				
				// Remove commas
				for (int k = 0; k < lines[i].length; k++) {
					if (lines[i][k] == ",") {
						if (lines[i].length == 1) {
							lines[i] = "";
						} else if (k == 0) {
							lines[i] = lines[i].substring(1);
						} else if ((k + 1) == lines[i].length) {
							lines[i] = lines[i].substring(0, lines[i].length - 1);
						} else {
							lines[i] = lines[i].substring(0, k) + " " + lines[i].substring(k + 1);
						}
					}
				}
				
				// Remove unneeded spaces
				for (int k = 0; k < lines[i].length; k++) {
					if (lines[i][k] == " ") {
						boolean found = false;
						for (int v = k; v < lines[i].length; v++) {
							if (lines[i][v] != " ") {
								found = true;
								if (k == 0) {
									lines[i] = lines[i].substring(v);
								} else {
									lines[i] = lines[i].substring(0, k + 1) + lines[i].substring(v);
								}
								
								break;
							}
						}
						
						if (!found) {
							if (k == 0) {
								lines[i] = "";
							} else {
								lines[i] = lines[i].substring(0, k);
							}
						}
					}
				}
			}
		}
	}
	
	
	// METHODS //
	public void compile() {
		for (int i = 0; i < lines.length; i++) {
			if (lines[i].length == 0) continue;
			
			String[] cmd = splitTokens(lines[i], " ");
			
			for (int k = 0; k < cmd.length; k++)
				cmd[k] = cmd[k].toUpperCase();
			
			if (cmd[0][cmd[0].length - 1] == ":") {
				aliasName.add(cmd[0].substring(0, cmd[0].length - 1).toUpperCase());
				
				int counter = 0;
				for (int v = 0; v < compiledLines.size(); v++) {
					counter++;
					String str = compiledLines.get(v);
					int ph = 0;
					while (ph != -1) {
						for (int k = ph; k < str.length; k++) {
							if (str[k] == " ") {
								ph = k;
								break;
							}
							if ((k + 1) == str.length)
								ph = -1;
						}
						
						if (ph != -1) {
							ph++;
							counter++;
						}
					}
				}
				aliasAddress.add(counter);
			} else {
				switch (cmd[0]) {
					case("MOV"):
						c_mov(cmd);
						break;
					case("MOVC"):
						c_movc(cmd);
						break;
					case("INC"):
						c_inc(cmd);
						break;
					case("DEC"):
						c_dec(cmd);
						break;
					case("CLR"):
						c_clr(cmd);
						break;
					case("CPL"):
						c_cpl(cmd);
						break;
					case("SETB"):
						c_setb(cmd);
						break;
					case("JMP"):
					case("JZ"):
					case("JNZ"):
						c_jmp(cmd);
						break;
					case("JB"):
					case("JNB"):
						c_jb(cmd);
						break;
					case("DJNZ"):
						c_djnz(cmd);
						break;
					case("CJNE"):
						c_cjne(cmd);
						break;
					case("CALL"):
						c_call(cmd);
						break;
					case("RET"):
						c_ret(cmd);
						break;
					case("DB"):
						c_db(cmd);
						break;
					default:
						err(cmd[0], "Unknown command!");
				}
				
				
				if (error)
					return;
			}
		}
		
		// Finalize jmp commands
		for (int i = 0; i < compiledLines.size(); i++) {
			String[] cmd = splitTokens(compiledLines.get(i), " ");
			int adr = -1;
			switch (cmd[0]) {
				case("JMP"):
					adr = getAliasAddress(cmd[1]);
					compiledLines.set(i, 0x80 + " " + adr);
					break;
				case("CALL"):
					adr = getAliasAddress(cmd[1]);
					compiledLines.set(i, 0x12 + " " + adr + " 0");
					break;
				case("JB"):
					adr = getAliasAddress(cmd[2]);
					compiledLines.set(i, 0x20 + " " + convBitaddress(cmd[1]) + " " + adr);
					break;
				case("JNB"):
					adr = getAliasAddress(cmd[2]);
					compiledLines.set(i, 0x30 + " " + convBitaddress(cmd[1]) + " " + adr);
					break;
				case("JZ"):
					adr = getAliasAddress(cmd[1]);
					compiledLines.set(i, 0x60 + " " + adr);
					break;
				case("JNZ"):
					adr = getAliasAddress(cmd[1]);
					compiledLines.set(i, 0x70 + " " + adr);
					break;
				case("DJNZ"):
					;if (cmd.length == 3) {
						adr = getAliasAddress(cmd[2]);
						compiledLines.set(i, 0xD5 + " " + convAddress(cmd[1]) + " " + adr);
					} else {
						String[] phSplit = splitTokens(cmd[1], "-");
						adr = getAliasAddress(phSplit[1]);
						compiledLines.set(i, (0xD8 + int(phSplit[0][1])) + " " + adr);
					}
					
					break;
				case("CJNE"):
					adr = getAliasAddress(cmd[2]);
					String[] phSplit = splitTokens(cmd[1], "-");
					
					if (phSplit[0] == "A") {
						compiledLines.set(i, 0xB4 + " " + convConstant(phSplit[1]) + " " + adr);
					} else {
						compiledLines.set(i, (0xB8 + int(phSplit[0][1])) + " " + convConstant(phSplit[1]) + " " + adr);
					}
					
					break;
				case("DPTR"):
					adr = getAliasAddress(cmd[1]);
					compiledLines.set(i, 0x90 + " " + adr + " 0");
					break;
				default:
					// its not a jump command
					adr = 999;
					break;
			}
			
			if (adr == -1) {
				err(cmd[0], "Couldn't find address of '" + cmd[1] + "' !");
			}
		}
		
		
		if (!error)
			println("[COMPILER] Success! (Timestamp: " + millis() + ")");
	}
	
	
	public void overwriteController(MicroController controller) {
		if (error)
			println("[COMPILER] Cannot overwrite with errors!");
		
		controller.PC = 0;
		controller.A = 0;
		controller.DPTR = 0;
		controller.SP = 0x07;
		
		for (int i = 0; i < controller.programData.length; i++)
			controller.programData[i] = 0;
		for (int i = 0; i < controller.ramData.length; i++)
			controller.ramData[i] = 0;
		for (int i = 0; i < controller.ramSfr.length; i++)
			controller.ramSfr[i] = 0;
		
		
		int counter = 0;
		for (int i = 0; i < compiledLines.size(); i++) {
			String[] cmd = splitTokens(compiledLines.get(i), " ");
			
			if (cmd.length != 0) {
				for (int k = 0; k < cmd.length; k++) {
					controller.programData[counter] = int(cmd[k]);
					counter++;
				}
			} else {
				controller.programData[counter] = int(compiledLines.get(i));
				counter++;
			}
		}
	}
	
	
	// *********************** //
	// ** COMPILING METHODS ** //
	// *********************** //
	
	
	void c_mov(String[] cmd) {
		if (cmd.length != 3) {
			err(cmd[0], "Expecting 2 parameters!");
		} else {
			int compLinesCount = compiledLines.size();
			
			// nested switch-case is bugged for some reason
			// need to call any function before opening another switch-case
			// thats why theres a semicolon at each case of the first one
			
			switch (getTypeOf(cmd[1])) {
				case(TYPE_AKKU):; // MOV A, ...
					switch (getTypeOf(cmd[2])) {
						case(TYPE_CONSTANT):
							compiledLines.add(0x74 + " " + convConstant(cmd[2]));
							break;
						case(TYPE_REGISTER):
							compiledLines.add((0xE8 + int(cmd[2][1])) + "");
							break;
						case(TYPE_ADDRESS):
							compiledLines.add(0xE5 + " " + convAddress(cmd[2]));
							break;
						case(TYPE_AT_REGISTER):
							compiledLines.add((0xE6 + int(cmd[2][2])) + "");
							break;
					}
					break;
				case(TYPE_REGISTER):; // MOV Rn, ...
					switch (getTypeOf(cmd[2])) {
						case(TYPE_CONSTANT):
							compiledLines.add((int(cmd[1][1]) + 0x78) + " " + convConstant(cmd[2]));
							break;
						case(TYPE_AKKU):
							compiledLines.add((0xF8 + int(cmd[1][1])) + "");
							break;
						case(TYPE_ADDRESS):
							compiledLines.add((0xA8 + int(cmd[1][1])) + " " + convAddress(cmd[2]));
							break;
					}
					break;
				case(TYPE_ADDRESS):; // MOV dadr, ...
					switch (getTypeOf(cmd[2])) {
						case(TYPE_CONSTANT):
							compiledLines.add(0x75 + " " + convAddress(cmd[1]) + " " + convConstant(cmd[2]));
							break;
						case(TYPE_AKKU):
							compiledLines.add(0xF5 + " " + convAddress(cmd[1]));
							break;
						case(TYPE_REGISTER):
							compiledLines.add((0x88 + int(cmd[2][1])) + " " + convAddress(cmd[1]));
							break;
						case(TYPE_ADDRESS):
							compiledLines.add(0x85 + " " + convAddress(cmd[1]) + " " + convAddress(cmd[2]));
							break;
						case(TYPE_AT_REGISTER):
							compiledLines.add((0x86 + int(cmd[2][2])) + " " + convAddress(cmd[1]));
							break;
					}
					break;
				case(TYPE_AT_REGISTER):;
					switch (getTypeOf(cmd[2])) {
						case(TYPE_AKKU):
							compiledLines.add((0xF6 + int(cmd[1][2])) + "");
							break;
						case(TYPE_ADDRESS):
							compiledLines.add((0xA6 + int(cmd[1][2])) + " " + convAddress(cmd[2]));
							break;
						case(TYPE_CONSTANT):
							compiledLines.add((0x76 + int(cmd[1][2])) + " " + convConstant(cmd[2]));
							break;
					}
					break;
				case(TYPE_DPTR):;
					if (isTypeOf(cmd[2], TYPE_CONSTANT)) {
						compiledLines.add("DPTR " + cmd[2].substring(1, cmd[2].length) + " 0");
					}
					break;
			}
			
			
			if (compLinesCount == compiledLines.size()) {
				err(cmd[0], "Unknown combination!");
			}
		}
	}
	
	void c_movc(String[] cmd) {
		if (cmd.length != 3) {
			err(cmd[0], "Expecting 2 parameters!");
		} else {
			if (isTypeOf(cmd[1], TYPE_AKKU)) {
				String[] phSplit = splitTokens(cmd[2], "+");
				if (phSplit.length == 2 && phSplit[0] == "@A") {
					if (phSplit[1] == "DPTR") {
						compiledLines.add(0x93 + "");
					} else if (phSplit[1] == "PC") {
						compiledLines.add(0x83 + "");
					} else {
						err(cmd[0], "Unknown combination!");
					}
				} else {
					err(cmd[0], "Unknown combination!");
				}
			} else {
				err(cmd[0], "Unknown combination!");
			}
		}
	}
	
	void c_inc(String[] cmd) {
		if (cmd.length != 2) {
			err(cmd[0], "Expecting 1 parameter!");
		} else {
			switch (getTypeOf(cmd[1])) {
				case(TYPE_AKKU):
					compiledLines.add(0x04 + "");
					break;
				case(TYPE_REGISTER):
					compiledLines.add((int(cmd[1][1]) + 0x08) + "");
					break;
				case(TYPE_ADDRESS):
					compiledLines.add(0x05 + " " + convAddress(cmd[1]));
					break;
				case(TYPE_AT_REGISTER):
					compiledLines.add((int(cmd[1][1]) + 0x06) + "");
					break;
				default:
					err(cmd[0], "Unknown combination!");
					break;
			}
		}
	}
	
	void c_dec(String[] cmd) {
		if (cmd.length != 2) {
			err(cmd[0], "Expecting 1 parameter!");
		} else {
			switch (getTypeOf(cmd[1])) {
				case(TYPE_AKKU):
					compiledLines.add(0x14 + "");
					break;
				case(TYPE_REGISTER):
					compiledLines.add((int(cmd[1][1]) + 0x18) + "");
					break;
				case(TYPE_ADDRESS):
					compiledLines.add(0x15 + " " + convAddress(cmd[1]));
					break;
				case(TYPE_AT_REGISTER):
					compiledLines.add((int(cmd[1][1]) + 0x16) + "");
					break;
				default:
					err(cmd[0], "Unknown combination!");
					break;
			}
		}
	}
	
	void c_clr(String[] cmd) {
		if (cmd.length != 2) {
			err(cmd[0], "Expecting 1 parameter!");
		} else {
			switch (getTypeOf(cmd[1])) {
				case(TYPE_AKKU):
					compiledLines.add(0xE4 + "");
					break;
				case(TYPE_BITADDRESS):
					compiledLines.add(0xC2 + " " + convBitaddress(cmd[1]));
					break;
				default:
					err(cmd[0], "Unknown combination!");
					break;
			}
		}
	}
	
	void c_cpl(String[] cmd) {
		if (cmd.length != 2) {
			err(cmd[0], "Expecting 1 parameter!");
		} else {
			switch (getTypeOf(cmd[1])) {
				case(TYPE_AKKU):
					compiledLines.add(0xF4 + "");
					break;
				case(TYPE_BITADDRESS):
					compiledLines.add(0xB2 + " " + convBitaddress(cmd[1]));
					break;
				default:
					err(cmd[0], "Unknown combination! " + getTypeOf(cmd[1]) + " " + cmd[1]);
					break;
			}
		}
	}
	
	void c_setb(String[] cmd) {
		if (cmd.length != 2) {
			err(cmd[0], "Expecting 1 parameter!");
		} else {
			if (getTypeOf(cmd[1]) == TYPE_BITADDRESS) {
				compiledLines.add(0xD2 + " " + convBitaddress(cmd[1]));
			} else {
				err(cmd[0], "Unknown combination! " + getTypeOf(cmd[1]) + " " + cmd[1]);
			}
		}
	}
	
	void c_jmp(String[] cmd) {
		if (cmd.length != 2) {
			err(cmd[0], "Expecting 1 parameter!");
		} else {
			compiledLines.add(cmd[0] + " " + cmd[1]);
		}
	}
	void c_call(String[] cmd) {
		if (cmd.length != 2) {
			err(cmd[0], "Expecting 1 parameter!");
		} else {
			compiledLines.add(cmd[0] + " " + cmd[1] + " 0");
		}
	}
	void c_ret(String[] cmd) {
		if (cmd.length != 1) {
			err(cmd[0], "Expecting 0 parameters!");
		} else {
			compiledLines.add(0x22 + "");
		}
	}
	void c_jb(String[] cmd) {
		if (cmd.length != 3) {
			err(cmd[0], "Expecting 2 parameters!");
		} else {
			if (isTypeOf(cmd[1], TYPE_BITADDRESS)) {
				compiledLines.add(cmd[0] + " " + cmd[1] + " " + cmd[2]);
			} else {
				err(cmd[0], "Unknown combination!");
			}
		}
	}
	void c_djnz(String[] cmd) {
		if (cmd.length != 3) {
			err(cmd[0], "Expecting 2 parameters!");
		} else {
			switch (getTypeOf(cmd[1])) {
				case(TYPE_REGISTER):
					// MUST check for the '-' in the finishing compiler!
					compiledLines.add("DJNZ " + cmd[1] + "-" + cmd[2]);
					break;
				case(TYPE_ADDRESS):
					compiledLines.add("DJNZ " + cmd[1] + " " + cmd[2]);
					break;
				default:
					err(cmd[0], "Unknown combination!");
					break;
			}
		}
	}
	void c_cjne(String[] cmd) {
		if (cmd.length != 4) {
			err(cmd[0], "Expecting 3 parameters!");
		} else {
			// MUST check for the '-' in the finishing compiler!
			compiledLines.add("CJNE " + cmd[1] + "-" + cmd[2] + " " + cmd[3]);
			
			if (getTypeOf(cmd[1]) != TYPE_REGISTER && getTypeOf(cmd[1]) != TYPE_AKKU ||
				getTypeOf(cmd[2]) != TYPE_CONSTANT) {
				err(cmd[0], "Unknown combination!");
			}
		}
	}
	
	void c_db(String[] cmd) {
		String str = "";
		for (int i = 1; i < cmd.length; i++) {
			if (isTypeOf(cmd[i], TYPE_ADDRESS)) {
				str += convAddress(cmd[i]);
				if ((i + 1) != cmd.length)
					str += " ";
			} else {
				err(cmd[0], "Only accepting addresses!");
			}
		}
		
		compiledLines.add(str);
	}
	
	
	int convAddress(String adr) {
		if (adr[adr.length - 1] == "D")
			return int(adr.substring(0, adr.length - 1));
		else if (adr[adr.length - 1] == "B")
			return unbinary(adr.substring(0, adr.length - 1));
		else if (adr[adr.length - 1] == "H")
			return unhex(adr.substring(0, adr.length - 1));
		
		return int(adr);
	}
	int convConstant(String cns) {
		return convAddress(cns.substring(1));
	}
	int convBitaddress(String adr) {
		return convAddress(adr.substring(0, adr.length - 2)) * 8 + int(adr[adr.length - 1]);
	}
	
	
	boolean isAddress(String str) {
		if (int(str) != 0) {
			return true;
		} else {
			for (int i = 0; i < str.length; i++) {
				if (str[i] != "0") {
					return false;
				}
			}
			return true;
		}
	}
	
	int getAliasAddress(String str) {
		for (int i = 0; i < aliasName.size(); i++) {
			if (aliasName.get(i) == str)
				return aliasAddress.get(i);
		}
		return -1;
	}
	
	
	/*private final int TYPE_CMD = 0;
	private final int TYPE_CONSTANT = 1;
	private final int TYPE_ADDRESS = 2;
	private final int TYPE_REGISTER = 3;
	private final int TYPE_AT_REGISTER = 4;*/
	int getTypeOf(String str) {
		if (str == "A") {
			return TYPE_AKKU;
		} else if (str == "DPTR") {
			return TYPE_DPTR;
		}
		if (str[0] == "#") {
			return TYPE_CONSTANT;
		}
		if (str.length == 2) {
			if (str[0] == "R") {
				for (int i = 0; i < 8; i++) {
					if (str[1] == (i + "")) {
						return TYPE_REGISTER;
					}
				}
			}
		} else if (str.length == 3) {
			if (str[0] == "@" && str[1] == "R") {
				for (int i = 0; i < 8; i++) {
					if (str[2] == (i + "")) {
						return TYPE_AT_REGISTER;
					}
				}
			}
		}
		
		if (str[str.length - 2] == "." &&
			getTypeOf(str.substring(0, str.length - 2)) == TYPE_ADDRESS) {
			return TYPE_BITADDRESS;
		}
		
		if (convAddress(str) != 0) {
			return TYPE_ADDRESS;
		} else {
			boolean found = false;
			for (int i = 0; i < (str.length - 1); i++) {
				if (str[i] != "0") {
					found = true;
					break;
				}
			}
			
			if (!found) {
				found = true;
				switch (str[str.length - 1]) {
					case("D"):
					case("H"):
					case("B"):
						found = false;
						break;
				}
				
				if (found && (int(str[str.length - 1]) != 0 || str[str.length - 1] == "0"))
					found = false;
			}
			
			if (!found) return TYPE_ADDRESS;
		}
		
		return TYPE_CMD;
	}
	boolean isTypeOf(String str, int pType) {
		return (getTypeOf(str) == pType);
	}
	
	
	void err(String cause, String msg) {
		println("[COMPILER] (" + cause + ") " + msg);
		error = true;
	}
}
