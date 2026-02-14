package com.mk.autosecure.rest_fleet.request;

public class SettingBody {

    public SettingBody(SettingsBean settings) {
        this.settings = settings;
    }

    /**
     * settings : {"rotate":"normal"}
     */

    public SettingsBean settings;

    public static class SettingsBean {

        public SettingsBean(String rotate) {
            this.rotate = rotate;
        }

        /**
         * rotate : normal
         */

        public String rotate;

    }
}
