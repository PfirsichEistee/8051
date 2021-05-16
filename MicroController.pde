public class MicroController {
	// ATTRIBUTES //
	public char[] programData;
	public char[] ramData;
	public char[] ramSfr;
	
	public int PC; // Program counter
	public int DPTR;
	public int A;
	public int SP; // stack pointer
	
	
	// CONSTRUCTOR //
	public MicroController() {
		println("[MC] Preparing program data...");
		programData = new char[0xFFFF + 1];
		for (int i = 0; i < programData.length; i++) programData[i] = 0;
		
		println("[MC] Preparing ram data...");
		ramData = new char[0xFF + 1];
		for (int i = 0; i < ramData.length; i++) ramData[i] = 0;
		
		println("[MC] Preparing ram sfr...");
		ramSfr = new char[0xFF - 0x80 + 1];
		for (int i = 0; i < ramSfr.length; i++) ramSfr[i] = 0;
		
		PC = 0;
		DPTR = 0;
		A = 0;
		SP = 0x07;
		
		//debugPrepare();
	}
	
	
	// METHODS //
	public void exec() {
		// Execute current command
		switch (programData[PC]) {
			// DATENTRANSPORT
			case(0x74): // MOV A, #c8
				A = programData[PC + 1];
				PC += 2;
				break;
			case(0x78): // MOV R0, #c8
			case(0x79):
			case(0x7A):
			case(0x7B):
			case(0x7C):
			case(0x7D):
			case(0x7E):
			case(0x7F):
				ramData[programData[PC] - 0x78] = programData[PC + 1];
				PC += 2;
				break;
			case(0x75): // MOV dadr, #c8
				;if (programData[PC + 1] < 0x80)
					ramData[programData[PC + 1]] = programData[PC + 2];
				else
					ramSfr[programData[PC + 1] - 0x80] = programData[PC + 2];
				
				PC += 3;
				break;
			case(0xE8): // MOV A, Rn
			case(0xE9):
			case(0xEA):
			case(0xEB):
			case(0xEC):
			case(0xED):
			case(0xEE):
			case(0xEF):
				A = ramData[programData[PC] - 0xE8];
				PC++;
				break;
			case(0xF8): // MOV Rn, A
			case(0xF9):
			case(0xFA):
			case(0xFB):
			case(0xFC):
			case(0xFD):
			case(0xFE):
			case(0xFF):
				ramData[programData[PC] - 0xF8] = A;
				PC++;
				break;
			case(0xE5): // MOV A, dadr
				;if (programData[PC + 1] < 0x80)
					A = ramData[programData[PC + 1]];
				else
					A = ramSfr[programData[PC + 1] - 0x80];
				
				PC += 2;
				break;
			case(0xF5): // MOV dadr, A
				;if (programData[PC + 1] < 0x80)
					ramData[programData[PC + 1]] = A;
				else
					ramSfr[programData[PC + 1] - 0x80] = A;
				
				PC += 2;
				break;
			case(0xA8): // MOV Rn, dadr
			case(0xA9):
			case(0xAA):
			case(0xAB):
			case(0xAC):
			case(0xAD):
			case(0xAE):
			case(0xAF):
				;if (programData[PC + 1] < 0x80)
					ramData[programData[PC] - 0xA8] = ramData[programData[PC + 1]];
				else
					ramData[programData[PC] - 0xA8] = ramSfr[programData[PC + 1] - 0x80];
				
				PC += 2;
				break;
			case(0x88): // MOV dadr, Rn
			case(0x89):
			case(0x8A):
			case(0x8B):
			case(0x8C):
			case(0x8D):
			case(0x8E):
			case(0x8F):
				;if (programData[PC + 1] < 0x80)
					ramData[programData[PC + 1]] = ramData[programData[PC] - 0x88];
				else
					ramSfr[programData[PC + 1] - 0x80] = ramData[programData[PC] - 0x88];
				
				PC += 2;
				break;
			case(0x8F): // MOV dadr, dadr
				;if (programData[PC + 1] < 0x80 && programData[PC + 2] < 0x80)
					ramData[programData[PC + 1]] = ramData[programData[PC + 2]];
				else if (programData[PC + 1] < 0x80)
					ramData[programData[PC + 1]] = ramSfr[programData[PC + 2] - 0x80];
				else
					ramSfr[programData[PC + 1] - 0x80] = ramData[programData[PC + 2]];
				
				PC += 3;
				break;
			case(0xE6): // MOV A, @Rn
			case(0xE7):
				A = ramData[ramData[programData[PC] - 0xE6]];
				PC++;
				break;
			case(0xF6): // MOV @Rn, A
			case(0xF7):
				ramData[ramData[programData[PC] - 0xF6]] = A;
				PC++;
				break;
			case(0x86): // MOV dadr, @Rn
			case(0x87):
				;if (programData[PC + 1] < 0x80)
					ramData[programData[PC + 1]] = ramData[ramData[programData[PC] - 0x86]];
				else
					ramSfr[programData[PC + 1] - 0x80] = ramData[ramData[programData[PC] - 0x86]];
				
				PC += 2;
				break;
			case(0x76): // MOV @Rn, #c8
			case(0x77):
				ramData[ramData[programData[PC] - 0x76]] = programData[PC + 1];
				PC += 2;
				break;
			case(0xA6): // MOV @Rn, dadr
			case(0xA7):
				;if (programData[PC + 1] < 0x80)
					ramData[ramData[programData[PC] - 0xA6]] = ramData[programData[PC + 1]];
				else
					ramData[ramData[programData[PC] - 0xA6]] = ramSfr[programData[PC + 1] - 0x80];
				
				PC += 2;
				break;
			case(0x90): // MOV DPTR, #c16
				DPTR = programData[PC + 1];
				PC += 3;
				break;
			case(0x93): // MOVC A, @A+DPTR
				A = programData[A + DPTR];
				PC++;
				break;
			case(0x83): // MOVC A, @A+PC
				A = programData[A + PC];
				PC++;
				break;
			// >>> ARITHMETISCHE OPERATIONEN
			case(0x04): // INC A
				A++;
				A %= 256;
				PC++;
				break;
			case(0x08): // INC Rn
			case(0x09):
			case(0x0A):
			case(0x0B):
			case(0x0C):
			case(0x0D):
			case(0x0E):
			case(0x0F):
				ramData[programData[PC] - 0x08]++;
				ramData[programData[PC] - 0x08] %= 256;
				PC++;
				break;
			case(0x05): // INC dadr
				;if (programData[PC + 1] < 0x80) {
					ramData[programData[PC + 1]]++;
					ramData[programData[PC + 1]] %= 256;
				} else {
					ramSfr[programData[PC + 1] - 0x80]++;
					ramSfr[programData[PC + 1] - 0x80] %= 256;
				}
				PC += 2;
				break;
			case(0x06): // INC @Rn
			case(0x07):
				ramData[ramData[programData[PC] - 0x06]]++;
				ramData[ramData[programData[PC] - 0x06]] %= 256;
				PC++;
				break;
			case(0x14): // DEC A
				A--;
				if (A < 0) A = 255;
				PC++
				break;
			case(0x18): // DEC Rn
			case(0x19):
			case(0x1A):
			case(0x1B):
			case(0x1C):
			case(0x1D):
			case(0x1E):
			case(0x1F):
				ramData[programData[PC] - 0x18]--;
				if (ramData[programData[PC] - 0x18] < 0) ramData[programData[PC] - 0x18] = 255;
				PC++;
				break;
			case(0x15): // DEC dadr
				;if (programData[PC + 1] < 0x80) {
					ramData[programData[PC + 1]]--;
					if (ramData[programData[PC + 1]] < 0)
						ramData[programData[PC + 1]] = 255;
				} else {
					ramSfr[programData[PC + 1] - 0x80]--;
					if (ramSfr[programData[PC + 1] - 0x80] < 0)
						ramSfr[programData[PC + 1] - 0x80] = 255;
				}
				PC += 2;
				break;
			case(0x16): // DEC @Rn
			case(0x17):
				ramData[ramData[programData[PC] - 0x16]]--;
				if (ramData[ramData[programData[PC] - 0x16]] < 0)
					ramData[ramData[programData[PC] - 0x16]] = 255;
				PC++;
				break;
			case(0xE4): // CLR A
				A = 0;
				PC++;
				break;
			case(0xC2): // CLR bitaddresse
				;int phAdr = (int)(programData[PC + 1] / 8);
				int phBit = 0b11111110;
				for (int i = 0; i < (programData[PC + 1] - phAdr * 8); i++)
					phBit = (phBit << 1) | 0b00000001;
				
				if (phAdr < 0x80)
					ramData[phAdr] = ramData[phAdr] & phBit;
				else
					ramSfr[phAdr - 0x80] = ramSfr[phAdr - 0x80] & phBit;
				
				PC += 2;
				break;
			case(0xF4): // CPL A
				A = ~A;
				PC++;
				break;
			case(0xB2): // CPL bitaddresse
				;int phAdr = (int)(programData[PC + 1] / 8);
				int phBit = 0b00000001;
				for (int i = 0; i < (programData[PC + 1] - phAdr * 8); i++)
					phBit = phBit << 1;
				
				
				if (phAdr < 0x80)
					ramData[phAdr] = ramData[phAdr] ^ phBit;
				else
					ramSfr[phAdr - 0x80] = ramSfr[phAdr - 0x80] ^ phBit;
				
				PC += 2;
				break;
			case(0xD2): // SETB bitaddresse
				;int phAdr = (int)(programData[PC + 1] / 8);
				int phBit = 0b00000001;
				for (int i = 0; i < (programData[PC + 1] - phAdr * 8); i++)
					phBit = phBit << 1;
				
				
				if (phAdr < 0x80)
					ramData[phAdr] = ramData[phAdr] | phBit;
				else
					ramSfr[phAdr - 0x80] = ramSfr[phAdr - 0x80] | phBit;
				
				PC += 2;
				break;
			// >>> LOGISCHE OPERATIONEN
			// ...
			// >>> SPRUNGBEFEHLE
			case(0x80): // JMP address
				PC = programData[PC + 1];
				break;
			case(0x12): // LCALL address (here it's just CALL!)
				ramData[SP + 1] = PC + 3;
				SP += 2;
				PC = programData[PC + 1];
				break;
			case(0x20): // JB bitaddress
				;int phAdr = (int)(programData[PC + 1] / 8);
				int phBit = 0b00000001;
				for (int i = 0; i < (programData[PC + 1] - phAdr * 8); i++)
					phBit = phBit << 1;
				
				if (phAdr < 0x80)
					phBit = ramData[phAdr] & phBit;
				else
					phBit = ramSfr[phAdr - 0x80] & phBit;
				
				if (phBit != 0) {
					PC = programData[PC + 2];
				} else {
					PC += 3;
				}
				
				break;
			case(0x30): // JNB bitaddress
				;int phAdr = (int)(programData[PC + 1] / 8);
				int phBit = 0b00000001;
				for (int i = 0; i < (programData[PC + 1] - phAdr * 8); i++)
					phBit = phBit << 1;
				
				if (phAdr < 0x80)
					phBit = ramData[phAdr] & phBit;
				else
					phBit = ramSfr[phAdr - 0x80] & phBit;
				
				if (phBit == 0) {
					PC = programData[PC + 2];
				} else {
					PC += 3;
				}
				
				break;
			case(0x60): // JZ address
				;if (A == 0)
					PC = programData[PC + 1];
				else
					PC += 2;
				
				break;
			case(0x70): // JNZ address
				;if (A != 0)
					PC = programData[PC + 1];
				else
					PC += 2;
				
				break;
			case(0xD8): // DJNZ Rn, address
			case(0xD9):
			case(0xDA):
			case(0xDB):
			case(0xDC):
			case(0xDD):
			case(0xDE):
			case(0xDF):
				ramData[programData[PC] - 0xD8]--;
				if (ramData[programData[PC] - 0xD8] < 0)
					ramData[programData[PC] - 0xD8] = 255;
				
				if (ramData[programData[PC] - 0xD8] != 0)
					PC = programData[PC + 1];
				else
					PC += 2;
				
				break;
			case(0xD5): // DJNZ dadr, address
				;if (programData[PC + 1] < 0x80) {
					ramData[programData[PC + 1]]--;
					if (ramData[programData[PC + 1]] < 0)
						ramData[programData[PC + 1]] = 255;
				
					if (ramData[programData[PC + 1]] != 0)
						PC = programData[PC + 2];
					else
						PC += 3;
				} else {
					ramSfr[programData[PC + 1] - 0x80]--;
					if (ramSfr[programData[PC + 1] - 0x80] < 0)
						ramSfr[programData[PC + 1] - 0x80] = 255;
				
					if (ramSfr[programData[PC + 1] - 0x80] != 0)
						PC = programData[PC + 2];
					else
						PC += 3;
				}
				
				break;
			case(0xB4): // CJNE A, #c8, address
				;if (A != programData[PC + 1])
					PC = programData[PC + 2];
				else
					PC += 3;
				
				break;
			case(0xB8): // CJNE Rn, #c8, address
			case(0xB9):
			case(0xBA):
			case(0xBB):
			case(0xBC):
			case(0xBD):
			case(0xBE):
			case(0xBF):
				;if (ramData[programData[PC] - 0xB8] != programData[PC + 1])
					PC = programData[PC + 2];
				else
					PC += 3;
				
				break;
			case(0x22): // RET
				PC = ramData[SP - 1];
				SP -= 2;
				break;
			default:
				PC = 0;
				break;
		}
	}
	
	public int getSfr(int adr) {
		return ramSfr[adr - 0x80];
	}
	public void setSfr(int adr, int val) {
		ramSfr[adr - 0x80] = val;
	}
	
	
	/*private void debugPrepare() {
		programData[0] = 0x78; // MOV R0, ...
		programData[1] = 0x01; // constant 1
		programData[2] = 0x08; // inc R0
		programData[3] = 0x80; // jmp ...
		programData[4] = 0x00; // address 0
	}*/
}
