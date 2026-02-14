package com.mk.autosecure.rest.reponse;

/**
 * Created by doanvt on 2018/7/4.
 * Email：doanvt-hn@mk.com.vn
 */

public class LocationResponse {

    /**
     * address : {"country":"China","region":"Shanghai Shi","city":"","route":"Li Bing Lu","streetNumber":"","address":"Li Bing Lu, Pudong Xinqu, Shanghai Shi, China, 201203"}
     */

    private AddressBean address;

    public AddressBean getAddress() {
        return address;
    }

    public void setAddress(AddressBean address) {
        this.address = address;
    }

    public static class AddressBean {
        /**
         * country : China
         * region : Shanghai Shi
         * city :
         * route : Li Bing Lu
         * streetNumber :
         * address : Li Bing Lu, Pudong Xinqu, Shanghai Shi, China, 201203
         */

        private String country;
        private String region;
        private String city;
        private String route;
        private String streetNumber;
        private String address;

        public String getCountry() {
            return country;
        }

        public void setCountry(String country) {
            this.country = country;
        }

        public String getRegion() {
            return region;
        }

        public void setRegion(String region) {
            this.region = region;
        }

        public String getCity() {
            return city;
        }

        public void setCity(String city) {
            this.city = city;
        }

        public String getRoute() {
            return route;
        }

        public void setRoute(String route) {
            this.route = route;
        }

        public String getStreetNumber() {
            return streetNumber;
        }

        public void setStreetNumber(String streetNumber) {
            this.streetNumber = streetNumber;
        }

        public String getAddress() {
            return address;
        }

        public void setAddress(String address) {
            this.address = address;
        }

        @Override
        public String toString() {
            return "AddressBean{" +
                    "country='" + country + '\'' +
                    ", region='" + region + '\'' +
                    ", city='" + city + '\'' +
                    ", route='" + route + '\'' +
                    ", streetNumber='" + streetNumber + '\'' +
                    ", address='" + address + '\'' +
                    '}';
        }
    }

    @Override
    public String toString() {
        return "LocationResponse{" +
                "address=" + address +
                '}';
    }
}
