package com.mk.autosecure.ui;

import android.animation.Animator;
import android.animation.ObjectAnimator;
import android.animation.TypeEvaluator;
import android.content.Context;
import android.util.Property;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.mk.autosecure.ui.fragment.interfaces.LatLngInterpolator;

import java.util.ArrayList;
import java.util.List;

public class MarkerAnimation {
    static GoogleMap map;
    ArrayList<LatLng> _trips = new ArrayList<>() ;
    ArrayList<LatLng> _tripsOld = new ArrayList<>() ;
    Marker _marker;
    LatLngInterpolator _latLngInterpolator = new LatLngInterpolator.Spherical();

    public MarkerAnimation(List<LatLng> _trips, Marker _marker) {
        this._trips.addAll(_trips);
        this._tripsOld.addAll(_trips);
        this._marker = _marker;
    }


    public void animateMarker(MarkerAnimationInterface interfaceA) {
        TypeEvaluator<LatLng> typeEvaluator = new TypeEvaluator<LatLng>() {
            @Override
            public LatLng evaluate(float fraction, LatLng startValue, LatLng endValue) {
                return _latLngInterpolator.interpolate(fraction, startValue, endValue);
            }
        };
        Property<Marker, LatLng> property = Property.of(Marker.class, LatLng.class, "position");

        ObjectAnimator animator = ObjectAnimator.ofObject(_marker, property, typeEvaluator, _trips.get(0));

        //ObjectAnimator animator = ObjectAnimator.o(view, "alpha", 0.0f);
        animator.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationCancel(Animator animation) {
                //  animDrawable.stop();
            }

            @Override
            public void onAnimationRepeat(Animator animation) {
                //  animDrawable.stop();
            }

            @Override
            public void onAnimationStart(Animator animation) {
                //  animDrawable.stop();
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                //  animDrawable.stop();
                if (_trips.size() > 1) {
                    _trips.remove(0);
                    animateMarker(interfaceA);
                }else{
                    _trips.addAll(_tripsOld);
                    animateMarker(interfaceA);
                }
                if (interfaceA != null) interfaceA.onCallback(_trips);
            }
        });

        animator.setDuration(10);
        animator.start();
    }

    public interface MarkerAnimationInterface{
        void onCallback(List<LatLng> latLngs);
    }
}
