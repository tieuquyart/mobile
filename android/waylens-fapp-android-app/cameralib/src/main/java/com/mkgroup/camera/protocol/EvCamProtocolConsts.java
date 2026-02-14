package com.mkgroup.camera.protocol;

public interface EvCamProtocolConsts {
    String HEADER_PROTOCOL = "Protocol: EVCAM 1.0\r\n";
    String HEADER_TEXT_LENGTH = "TextLength: %d\r\n";
    String HEADER_BINARY_LENGTH = "BinaryLength: %d\r\n";
    String LINE_BREAK = "\r\n";

    String KEY_PROTOCOL = "Protocol: ";
    String KEY_TEXT_LENGTH = "TextLength: ";
    String KEY_BINARY_LENGTH = "BinaryLength: ";
}
