// framer-motion@12.34.0 downloaded from https://ga.jspm.io/npm:framer-motion@12.34.0/dist/es/index.mjs

import{jsx as t,Fragment as n}from"react/jsx-runtime";import*as o from"react";import{useId as r,useRef as s,useContext as c,useInsertionEffect as u,useMemo as l,Children as p,isValidElement as m,useState as w,createContext as y,useCallback as v,useEffect as x,useLayoutEffect as E,forwardRef as M}from"react";import{M as C,P,u as A,L as V,l as R,a as I,b as O,c as _,m as T,d as Y,e as j}from"../../_/CO5kLSXC.js";export{S as SwitchLayoutGroupContext,f as filterProps,i as isBrowser,g as isValidMotionProp}from"../../_/CO5kLSXC.js";import{u as D}from"../../_/FyZOJetw.js";import{isHTMLElement as X,frame as k,nodeGroup as L,resolveTransition as N,motionValue as B,cancelFrame as H,isMotionValue as W,collectMotionValues as $,transform as z,attachFollow as U,MotionValue as F,transformProps as G,acceleratedValues as J,hasReducedMotionListener as q,initPrefersReducedMotion as K,prefersReducedMotion as Q,setTarget as Z,animateVisualElement as tt,addDomEvent as et,rootProjectionNode as nt,optimizedAppearDataId as ot,startWaapiAnimation as rt,getOptimisedAppearId as st,VisualElement as it,createBox as ct,mixNumber as ut}from"motion-dom";export*from"motion-dom";export{VisualElement,addScaleCorrector,animateVisualElement,buildTransform,calcLength,createBox,delay,optimizedAppearDataAttribute,resolveMotionValue,visualElementStore}from"motion-dom";import{u as at,f as lt,c as ft,g as dt,a as pt,l as mt,d as ht}from"../../_/B8T0b54U.js";export{b as addPointerEvent,e as addPointerInfo,h as useIsPresent}from"../../_/B8T0b54U.js";import{warnOnce as gt,invariant as wt,wrap as yt,MotionGlobalConfig as vt,noop as xt,warning as Et,moveItem as bt}from"motion-utils";export*from"motion-utils";export{MotionGlobalConfig}from"motion-utils";import{u as Mt}from"../../_/C4kjU9Cj.js";export{a as useAnimateMini}from"../../_/C4kjU9Cj.js";import{s as Ct,c as Pt,i as St}from"../../_/C65H1e1X.js";export{a as animate,b as scrollInfo}from"../../_/C65H1e1X.js";export{a as animateMini}from"../../_/BY37RHPR.js";export{d as distance,a as distance2D}from"../../_/9OoNJDPy.js";import"../../_/YB9E9y_j.js";function At(t,e){if(typeof t==="function")return t(e);t!==null&&t!==void 0&&(t.current=e)}function Vt(...t){return e=>{let n=false;const o=t.map((t=>{const o=At(t,e);n||typeof o!=="function"||(n=true);return o}));if(n)return()=>{for(let e=0;e<o.length;e++){const n=o[e];typeof n==="function"?n():At(t[e],null)}}}}function Rt(...t){return o.useCallback(Vt(...t),t)}"use client";class PopChildMeasure extends o.Component{getSnapshotBeforeUpdate(t){const e=this.props.childRef.current;if(e&&t.isPresent&&!this.props.isPresent&&this.props.pop!==false){const t=e.offsetParent;const n=X(t)&&t.offsetWidth||0;const o=X(t)&&t.offsetHeight||0;const r=this.props.sizeRef.current;r.height=e.offsetHeight||0;r.width=e.offsetWidth||0;r.top=e.offsetTop;r.left=e.offsetLeft;r.right=n-r.width-r.left;r.bottom=o-r.height-r.top}return null}componentDidUpdate(){}render(){return this.props.children}}function It({children:e,isPresent:n,anchorX:i,anchorY:a,root:l,pop:f}){const d=r();const p=s(null);const m=s({width:0,height:0,top:0,left:0,right:0,bottom:0});const{nonce:h}=c(C);const g=e.props?.ref??e?.ref;const w=Rt(p,g);u((()=>{const{width:t,height:e,top:o,left:r,right:s,bottom:c}=m.current;if(n||f===false||!p.current||!t||!e)return;const u=i==="left"?`left: ${r}`:`right: ${s}`;const g=a==="bottom"?`bottom: ${c}`:`top: ${o}`;p.current.dataset.motionPopId=d;const w=document.createElement("style");h&&(w.nonce=h);const y=l??document.head;y.appendChild(w);w.sheet&&w.sheet.insertRule(`\n          [data-motion-pop-id="${d}"] {\n            position: absolute !important;\n            width: ${t}px !important;\n            height: ${e}px !important;\n            ${u}px !important;\n            ${g}px !important;\n          }\n        `);return()=>{y.contains(w)&&y.removeChild(w)}}),[n]);return t(PopChildMeasure,{isPresent:n,childRef:p,sizeRef:m,pop:f,children:f===false?e:o.cloneElement(e,{ref:w})})}"use client";const Ot=({children:e,initial:n,isPresent:s,onExitComplete:i,custom:c,presenceAffectsLayout:u,mode:a,anchorX:f,anchorY:d,root:p})=>{const m=D(_t);const h=r();let g=true;let w=l((()=>{g=false;return{id:h,initial:n,isPresent:s,custom:c,onExitComplete:t=>{m.set(t,true);for(const t of m.values())if(!t)return;i&&i()},register:t=>{m.set(t,false);return()=>m.delete(t)}}}),[s,m,i]);u&&g&&(w={...w});l((()=>{m.forEach(((t,e)=>m.set(e,false)))}),[s]);o.useEffect((()=>{!s&&!m.size&&i&&i()}),[s]);e=t(It,{pop:a==="popLayout",isPresent:s,anchorX:f,anchorY:d,root:p,children:e});return t(P.Provider,{value:w,children:e})};function _t(){return new Map}const Tt=t=>t.key||"";function Yt(t){const e=[];p.forEach(t,(t=>{m(t)&&e.push(t)}));return e}"use client";const jt=({children:e,custom:o,initial:r=true,onExitComplete:i,presenceAffectsLayout:u=true,mode:a="sync",propagate:f=false,anchorX:d="left",anchorY:p="top",root:m})=>{const[h,g]=at(f);const y=l((()=>Yt(e)),[e]);const v=f&&!h?[]:y.map(Tt);const x=s(true);const E=s(y);const b=D((()=>new Map));const M=s(new Set);const[C,P]=w(y);const[S,R]=w(y);A((()=>{x.current=false;E.current=y;for(let t=0;t<S.length;t++){const e=Tt(S[t]);if(v.includes(e)){b.delete(e);M.current.delete(e)}else b.get(e)!==true&&b.set(e,false)}}),[S,v.length,v.join("-")]);const I=[];if(y!==C){let t=[...y];for(let e=0;e<S.length;e++){const n=S[e];const o=Tt(n);if(!v.includes(o)){t.splice(e,0,n);I.push(n)}}a==="wait"&&I.length&&(t=I);R(Yt(t));P(y);return null}process.env.NODE_ENV!=="production"&&a==="wait"&&S.length>1&&console.warn('You\'re attempting to animate multiple children within AnimatePresence, but its mode is set to "wait". This will lead to odd visual behaviour.');const{forceRender:O}=c(V);return t(n,{children:S.map((e=>{const n=Tt(e);const s=!(f&&!h)&&(y===S||v.includes(n));const c=()=>{if(M.current.has(n))return;M.current.add(n);if(!b.has(n))return;b.set(n,true);let t=true;b.forEach((e=>{e||(t=false)}));if(t){O?.();R(E.current);f&&g?.();i&&i()}};return t(Ot,{isPresent:s,initial:!(x.current&&!r)&&void 0,custom:o,presenceAffectsLayout:u,mode:a,root:m,onExitComplete:s?void 0:c,anchorX:d,anchorY:p,children:e},n)}))})};"use client";
/**
 * Note: Still used by components generated by old versions of Framer
 *
 * @deprecated
 */const Dt=y(null);"use client";function Xt(){const t=s(false);A((()=>{t.current=true;return()=>{t.current=false}}),[]);return t}"use client";function kt(){const t=Xt();const[e,n]=w(0);const o=v((()=>{t.current&&n(e+1)}),[e]);const r=v((()=>k.postRender(o)),[o]);return[r,e]}"use client";const Lt=t=>t===true;const Nt=t=>Lt(t===true)||t==="id";const Bt=({children:e,id:n,inherit:o=true})=>{const r=c(V);const i=c(Dt);const[u,a]=kt();const f=s(null);const d=r.id||i;if(f.current===null){Nt(o)&&d&&(n=n?d+"-"+n:d);f.current={id:n,group:Lt(o)&&r.group||L()}}const p=l((()=>({...f.current,forceRender:u})),[a]);return t(V.Provider,{value:p,children:e})};"use client";function Ht({children:e,features:n,strict:o=false}){const[,r]=w(!Wt(n));const i=s(void 0);if(!Wt(n)){const{renderer:t,...e}=n;i.current=t;R(e)}x((()=>{Wt(n)&&n().then((({renderer:t,...e})=>{R(e);i.current=t;r(true)}))}),[]);return t(I.Provider,{value:{renderer:i.current,strict:o},children:e})}function Wt(t){return typeof t==="function"}"use client";function $t({children:e,isValidProp:n,...o}){n&&O(n);const r=c(C);o={...r,...o};o.transition=N(o.transition,r.transition);o.isStatic=D((()=>o.isStatic));const s=l((()=>o),[JSON.stringify(o.transition),o.transformPagePoint,o.reducedMotion,o.skipAnimations]);return t(C.Provider,{value:s,children:e})}function zt(t,e){if(typeof Proxy==="undefined")return _;const n=new Map;const o=(n,o)=>_(n,o,t,e);const r=(t,e)=>{process.env.NODE_ENV!=="production"&&gt(false,"motion() is deprecated. Use motion.create() instead.");return o(t,e)};return new Proxy(r,{get:(r,s)=>{if(s==="create")return o;n.has(s)||n.set(s,_(s,void 0,t,e));return n.get(s)}})}const Ut=zt();const Ft=zt(lt,ft);"use client";const Gt={renderer:ft,...pt,...dt};"use client";const Jt={...Gt,...ht,...mt};"use client";const qt={renderer:ft,...pt};"use client";function Kt(t,e,n){u((()=>t.on(e,n)),[t,e,n])}"use client";const Qt=()=>({scrollX:B(0),scrollY:B(0),scrollXProgress:B(0),scrollYProgress:B(0)});const Zt=t=>!!t&&!t.current;function te({container:t,target:e,...n}={}){const o=D(Qt);o.scrollXProgress.accelerate={factory:o=>Ct(o,{...n,axis:"x",container:t?.current||void 0,target:e?.current||void 0}),times:[0,1],keyframes:[0,1],ease:t=>t,duration:1};o.scrollYProgress.accelerate={factory:o=>Ct(o,{...n,axis:"y",container:t?.current||void 0,target:e?.current||void 0}),times:[0,1],keyframes:[0,1],ease:t=>t,duration:1};const r=s(null);const i=s(false);const c=v((()=>{r.current=Ct(((t,{x:e,y:n})=>{o.scrollX.set(e.current);o.scrollXProgress.set(e.progress);o.scrollY.set(n.current);o.scrollYProgress.set(n.progress)}),{...n,container:t?.current||void 0,target:e?.current||void 0});return()=>{r.current?.()}}),[t,e,JSON.stringify(n.offset)]);A((()=>{i.current=false;if(!Zt(t)&&!Zt(e))return c();i.current=true}),[c]);x((()=>{if(i.current){wt(!Zt(t),"Container ref is defined but not hydrated","use-scroll-ref");wt(!Zt(e),"Target ref is defined but not hydrated","use-scroll-ref");return c()}}),[c]);return o}
/**
 * @deprecated useElementScroll is deprecated. Convert to useScroll({ container: ref })
 */function ee(t){process.env.NODE_ENV==="development"&&gt(false,"useElementScroll is deprecated. Convert to useScroll({ container: ref }).");return te({container:t})}
/**
 * @deprecated useViewportScroll is deprecated. Convert to useScroll()
 */function ne(){process.env.NODE_ENV!=="production"&&gt(false,"useViewportScroll is deprecated. Convert to useScroll().");return te()}"use client";
/**
 * Creates a `MotionValue` to track the state and velocity of a value.
 *
 * Usually, these are created automatically. For advanced use-cases, like use with `useTransform`, you can create `MotionValue`s externally and pass them into the animated component via the `style` prop.
 *
 * ```jsx
 * export const MyComponent = () => {
 *   const scale = useMotionValue(1)
 *
 *   return <motion.div style={{ scale }} />
 * }
 * ```
 *
 * @param initial - The initial state.
 *
 * @public
 */function oe(t){const e=D((()=>B(t)));const{isStatic:n}=c(C);if(n){const[,n]=w(t);x((()=>e.on("change",n)),[])}return e}"use client";function re(t,e){const n=oe(e());const o=()=>n.set(e());o();A((()=>{const e=()=>k.preRender(o,false,true);const n=t.map((t=>t.on("change",e)));return()=>{n.forEach((t=>t()));H(o)}}));return n}"use client";function se(t,...e){const n=t.length;function o(){let o="";for(let r=0;r<n;r++){o+=t[r];const n=e[r];n&&(o+=W(n)?n.get():n)}return o}return re(e.filter(W),o)}"use client";function ie(t){$.current=[];t();const e=re($.current,t);$.current=void 0;return e}"use client";function ce(t,e,n,o){if(typeof t==="function")return ie(t);const r=n!==void 0&&!Array.isArray(n)&&typeof e!=="function";if(r)return ae(t,e,n,o);const s=n;const i=typeof e==="function"?e:z(e,s,o);const c=Array.isArray(t)?ue(t,i):ue([t],(([t])=>i(t)));const u=Array.isArray(t)?void 0:t.accelerate;u&&!u.isTransformed&&typeof e!=="function"&&Array.isArray(n)&&o?.clamp!==false&&(c.accelerate={...u,times:e,keyframes:n,isTransformed:true,...o?.ease?{ease:o.ease}:{}});return c}function ue(t,e){const n=D((()=>[]));return re(t,(()=>{n.length=0;const o=t.length;for(let e=0;e<o;e++)n[e]=t[e].get();return e(n)}))}function ae(t,e,n,o){const r=D((()=>Object.keys(n)));const s=D((()=>({})));for(const i of r)s[i]=ce(t,e,n[i],o);return s}"use client";function le(t,e={}){const{isStatic:n}=c(C);const o=()=>W(t)?t.get():t;if(n)return ce(o);const r=oe(o());u((()=>U(r,t,e)),[r,JSON.stringify(e)]);return r}"use client";function fe(t,e={}){return le(t,{type:"spring",...e})}"use client";function de(t){const e=s(0);const{isStatic:n}=c(C);x((()=>{if(n)return;const o=({timestamp:n,delta:o})=>{e.current||(e.current=n);t(n-e.current,o)};k.update(o,true);return()=>H(o)}),[t])}"use client";function pe(){const t=oe(0);de((e=>t.set(e)));return t}"use client";function me(t){const e=oe(t.getVelocity());const n=()=>{const o=t.getVelocity();e.set(o);o&&k.update(n)};Kt(t,"change",(()=>{k.update(n,false,true)}));return e}class WillChangeMotionValue extends F{constructor(){super(...arguments);this.isEnabled=false}add(t){if(G.has(t)||J.has(t)){this.isEnabled=true;this.update()}}update(){this.set(this.isEnabled?"transform":"auto")}}"use client";function he(){return D((()=>new WillChangeMotionValue("auto")))}"use client";function ge(){!q.current&&K();const[t]=w(Q.current);process.env.NODE_ENV!=="production"&&gt(t!==true,"You have Reduced Motion enabled on your device. Animations may not appear as expected.","reduced-motion-disabled");return t}"use client";function we(){const t=ge();const{reducedMotion:e}=c(C);return e!=="never"&&(e==="always"||t)}function ye(t){t.values.forEach((t=>t.stop()))}function ve(t,e){const n=[...e].reverse();n.forEach((n=>{const o=t.getVariant(n);o&&Z(t,o);t.variantChildren&&t.variantChildren.forEach((t=>{ve(t,e)}))}))}function xe(t,e){if(Array.isArray(e))return ve(t,e);if(typeof e==="string")return ve(t,[e]);Z(t,e)}function Ee(){let t=false;const e=new Set;const n={subscribe(t){e.add(t);return()=>{e.delete(t)}},start(n,o){wt(t,"controls.start() should only be called after a component has mounted. Consider calling within a useEffect hook.");const r=[];e.forEach((t=>{r.push(tt(t,n,{transitionOverride:o}))}));return Promise.all(r)},set(n){wt(t,"controls.set() should only be called after a component has mounted. Consider calling within a useEffect hook.");return e.forEach((t=>{xe(t,n)}))},stop(){e.forEach((t=>{ye(t)}))},mount(){t=true;return()=>{t=false;n.stop()}}};return n}"use client";function be(){const t=D((()=>({current:null,animations:[]})));const e=we()??void 0;const n=l((()=>Pt({scope:t,reduceMotion:e})),[t,e]);Mt((()=>{t.animations.forEach((t=>t.stop()));t.animations.length=0}));return[t,n]}"use client";
/**
 * Creates `LegacyAnimationControls`, which can be used to manually start, stop
 * and sequence animations on one or more components.
 *
 * The returned `LegacyAnimationControls` should be passed to the `animate` property
 * of the components you want to animate.
 *
 * These components can then be animated with the `start` method.
 *
 * ```jsx
 * import * as React from 'react'
 * import { motion, useAnimation } from 'framer-motion'
 *
 * export function MyComponent(props) {
 *    const controls = useAnimation()
 *
 *    controls.start({
 *        x: 100,
 *        transition: { duration: 0.5 },
 *    })
 *
 *    return <motion.div animate={controls} />
 * }
 * ```
 *
 * @returns Animation controller with `start` and `stop` methods
 *
 * @public
 */function Me(){const t=D(Ee);A(t.mount,[]);return t}const Ce=Me;"use client";function Pe(){const t=c(P);return t?t.custom:void 0}"use client";
/**
 * Attaches an event listener directly to the provided DOM element.
 *
 * Bypassing React's event system can be desirable, for instance when attaching non-passive
 * event handlers.
 *
 * ```jsx
 * const ref = useRef(null)
 *
 * useDomEvent(ref, 'wheel', onWheel, { passive: false })
 *
 * return <div ref={ref} />
 * ```
 *
 * @param ref - React.RefObject that's been provided to the element you want to bind the listener to.
 * @param eventName - Name of the event you want listen for.
 * @param handler - Function to fire when receiving the event.
 * @param options - Options to pass to `Event.addEventListener`.
 *
 * @public
 */function Se(t,e,n,o){x((()=>{const r=t.current;if(n&&r)return et(r,e,n,o)}),[t,e,n,o])}class DragControls{constructor(){this.componentControls=new Set}subscribe(t){this.componentControls.add(t);return()=>this.componentControls.delete(t)}
/**
     * Start a drag gesture on every `motion` component that has this set of drag controls
     * passed into it via the `dragControls` prop.
     *
     * ```jsx
     * dragControls.start(e, {
     *   snapToCursor: true
     * })
     * ```
     *
     * @param event - PointerEvent
     * @param options - Options
     *
     * @public
     */start(t,e){this.componentControls.forEach((n=>{n.start(t.nativeEvent||t,e)}))}cancel(){this.componentControls.forEach((t=>{t.cancel()}))}stop(){this.componentControls.forEach((t=>{t.stop()}))}}const Ae=()=>new DragControls;function Ve(){return D(Ae)}function Re(t){return t!==null&&typeof t==="object"&&T in t}function Ie(t){if(Re(t))return t[T]}function Oe(){return _e}function _e(t){if(nt.current){nt.current.isUpdating=false;nt.current.blockUpdate();t&&t()}}function Te(){const t=v((()=>{const t=nt.current;t&&t.resetTree()}),[]);return t}"use client";
/**
 * Cycles through a series of visual properties. Can be used to toggle between or cycle through animations. It works similar to `useState` in React. It is provided an initial array of possible states, and returns an array of two arguments.
 *
 * An index value can be passed to the returned `cycle` function to cycle to a specific index.
 *
 * ```jsx
 * import * as React from "react"
 * import { motion, useCycle } from "framer-motion"
 *
 * export const MyComponent = () => {
 *   const [x, cycleX] = useCycle(0, 50, 100)
 *
 *   return (
 *     <motion.div
 *       animate={{ x: x }}
 *       onTap={() => cycleX()}
 *      />
 *    )
 * }
 * ```
 *
 * @param items - items to cycle through
 * @returns [currentState, cycleState]
 *
 * @public
 */function Ye(...t){const e=s(0);const[n,o]=w(t[e.current]);const r=v((n=>{e.current=typeof n!=="number"?yt(0,t.length,e.current+1):n;o(t[e.current])}),[t.length,...t]);return[n,r]}"use client";function je(t,{root:e,margin:n,amount:o,once:r=false,initial:s=false}={}){const[i,c]=w(s);x((()=>{if(!t.current||r&&i)return;const s=()=>{c(true);return r?void 0:()=>c(false)};const u={root:e&&e.current||void 0,margin:n,amount:o};return St(t.current,s,u)}),[e,t,n,r,o]);return i}"use client";function De(){const[t,e]=kt();const n=Oe();const o=s(-1);x((()=>{k.postRender((()=>k.postRender((()=>{e===o.current&&(vt.instantAnimations=false)}))))}),[e]);return r=>{n((()=>{vt.instantAnimations=true;t();r();o.current=e+1}))}}function Xe(){vt.instantAnimations=false}"use client";function ke(){const[t,e]=w(true);x((()=>{const t=()=>e(!document.hidden);document.hidden&&t();document.addEventListener("visibilitychange",t);return()=>{document.removeEventListener("visibilitychange",t)}}),[]);return t}
/**
 * Creates a `transformPagePoint` function that accounts for SVG viewBox scaling.
 *
 * When dragging SVG elements inside an SVG with a viewBox that differs from
 * the rendered dimensions (e.g., `viewBox="0 0 100 100"` but rendered at 500x500 pixels),
 * pointer coordinates need to be transformed to match the SVG's coordinate system.
 *
 * @example
 * ```jsx
 * function App() {
 *   const svgRef = useRef<SVGSVGElement>(null)
 *
 *   return (
 *     <MotionConfig transformPagePoint={transformViewBoxPoint(svgRef)}>
 *       <svg ref={svgRef} viewBox="0 0 100 100" width={500} height={500}>
 *         <motion.rect drag width={10} height={10} />
 *       </svg>
 *     </MotionConfig>
 *   )
 * }
 * ```
 *
 * @param svgRef - A React ref to the SVG element
 * @returns A transformPagePoint function for use with MotionConfig
 *
 * @public
 */function Le(t){return e=>{const n=t.current;if(!n)return e;const o=n.viewBox?.baseVal;if(!o||o.width===0&&o.height===0)return e;const r=n.getBoundingClientRect();if(r.width===0||r.height===0)return e;const s=o.width/r.width;const i=o.height/r.height;const c=r.left+window.scrollX;const u=r.top+window.scrollY;return{x:(e.x-c)*s+c,y:(e.y-u)*i+u}}}const Ne=new Map;const Be=new Map;const He=(t,e)=>{const n=G.has(e)?"transform":e;return`${t}: ${n}`};function We(t,e,n){const o=He(t,e);const r=Ne.get(o);if(!r)return null;const{animation:s,startTime:i}=r;function c(){window.MotionCancelOptimisedAnimation?.(t,e,n)}s.onfinish=c;if(i===null||window.MotionHandoffIsComplete?.(t)){c();return null}return i}let $e;let ze;const Ue=new Set;function Fe(){Ue.forEach((t=>{t.animation.play();t.animation.startTime=t.startTime}));Ue.clear()}function Ge(t,e,n,o,r){if(window.MotionIsMounted)return;const s=t.dataset[ot];if(!s)return;window.MotionHandoffAnimation=We;const i=He(s,e);if(!ze){ze=rt(t,e,[n[0],n[0]],{duration:1e4,ease:"linear"});Ne.set(i,{animation:ze,startTime:null});window.MotionHandoffAnimation=We;window.MotionHasOptimisedAnimation=(t,e)=>{if(!t)return false;if(!e)return Be.has(t);const n=He(t,e);return Boolean(Ne.get(n))};window.MotionHandoffMarkAsComplete=t=>{Be.has(t)&&Be.set(t,true)};window.MotionHandoffIsComplete=t=>Be.get(t)===true;window.MotionCancelOptimisedAnimation=(t,e,n,o)=>{const r=He(t,e);const s=Ne.get(r);if(s){n&&o===void 0?n.postRender((()=>{n.postRender((()=>{s.animation.cancel()}))})):s.animation.cancel();if(n&&o){Ue.add(s);n.render(Fe)}else{Ne.delete(r);Ne.size||(window.MotionCancelOptimisedAnimation=void 0)}}};window.MotionCheckAppearSync=(t,e,n)=>{const o=st(t);if(!o)return;const r=window.MotionHasOptimisedAnimation?.(o,e);const s=t.props.values?.[e];if(!r||!s)return;const i=n.on("change",(t=>{if(s.get()!==t){window.MotionCancelOptimisedAnimation?.(o,e);i()}}));return i}}const c=()=>{ze.cancel();const s=rt(t,e,n,o);$e===void 0&&($e=performance.now());s.startTime=$e;Ne.set(i,{animation:s,startTime:$e});r&&r(s)};Be.set(s,false);ze.ready?ze.ready.then(c).catch(xt):c()}"use client";const Je=()=>({});class StateVisualElement extends it{constructor(){super(...arguments);this.measureInstanceViewportBox=ct}build(){}resetTransform(){}restoreTransform(){}removeValueFromRenderState(){}renderInstance(){}scrapeMotionValuesFromProps(){return Je()}getBaseTargetFromProps(){}readValueFromInstance(t,e,n){return n.initialState[e]||0}sortInstanceNodePosition(){return 0}}const qe=Y({scrapeMotionValuesFromProps:Je,createRenderState:Je});function Ke(t){const[e,n]=w(t);const o=qe({},false);const r=D((()=>new StateVisualElement({props:{onUpdate:t=>{n({...t})}},visualState:o,presenceContext:null},{initialState:t})));E((()=>{r.mount({});return()=>r.unmount()}),[r]);const s=D((()=>t=>tt(r,t)));return[e,s]}"use client";let Qe=0;const Ze=({children:e})=>{o.useEffect((()=>{wt(false,"AnimateSharedLayout is deprecated: https://www.framer.com/docs/guide-upgrade/##shared-layout-animations")}),[]);return t(Bt,{id:D((()=>"asl-"+Qe++)),children:e})};"use client";const tn=1e5;const en=t=>t>.001?1/t:tn;let nn=false;
/**
 * Returns a `MotionValue` each for `scaleX` and `scaleY` that update with the inverse
 * of their respective parent scales.
 *
 * This is useful for undoing the distortion of content when scaling a parent component.
 *
 * By default, `useInvertedScale` will automatically fetch `scaleX` and `scaleY` from the nearest parent.
 * By passing other `MotionValue`s in as `useInvertedScale({ scaleX, scaleY })`, it will invert the output
 * of those instead.
 *
 * ```jsx
 * const MyComponent = () => {
 *   const { scaleX, scaleY } = useInvertedScale()
 *   return <motion.div style={{ scaleX, scaleY }} />
 * }
 * ```
 *
 * @deprecated
 */function on(t){let e=oe(1);let n=oe(1);const{visualElement:o}=c(j);wt(!!(t||o),"If no scale values are provided, useInvertedScale must be used within a child of another motion component.");Et(nn,"useInvertedScale is deprecated and will be removed in 3.0. Use the layout prop instead.");nn=true;if(t){e=t.scaleX||e;n=t.scaleY||n}else if(o){e=o.getValue("scaleX",1);n=o.getValue("scaleY",1)}const r=ce(e,en);const s=ce(n,en);return{scaleX:r,scaleY:s}}"use client";const rn=y(null);function sn(t,e,n,o){if(!o)return t;const r=t.findIndex((t=>t.value===e));if(r===-1)return t;const s=o>0?1:-1;const i=t[r+s];if(!i)return t;const c=t[r];const u=i.layout;const a=ut(u.min,u.max,.5);return s===1&&c.layout.max+n>a||s===-1&&c.layout.min+n<a?bt(t,r,r+s):t}"use client";function cn({children:e,as:n="ul",axis:o="y",onReorder:r,values:i,...c},u){const a=D((()=>Ft[n]));const l=[];const f=s(false);const d=s(null);wt(Boolean(i),"Reorder.Group must be provided a values prop","reorder-values");const p={axis:o,groupRef:d,registerItem:(t,e)=>{const n=l.findIndex((e=>t===e.value));n!==-1?l[n].layout=e[o]:l.push({value:t,layout:e[o]});l.sort(ln)},updateOrder:(t,e,n)=>{if(f.current)return;const o=sn(l,t,e,n);if(l!==o){f.current=true;r(o.map(an).filter((t=>i.indexOf(t)!==-1)))}}};x((()=>{f.current=false}));const m=t=>{d.current=t;typeof u==="function"?u(t):u&&(u.current=t)};const h={overflowAnchor:"none",...c.style};return t(a,{...c,style:h,ref:m,ignoreStrict:true,children:t(rn.Provider,{value:p,children:e})})}const un=M(cn);function an(t){return t.value}function ln(t,e){return t.layout.min-e.layout.min}const fn=50;const dn=25;const pn=new Set(["auto","scroll"]);const mn=new WeakMap;const hn=new WeakMap;let gn=null;function wn(){if(gn){const t=vn(gn,"y");if(t){hn.delete(t);mn.delete(t)}const e=vn(gn,"x");if(e&&e!==t){hn.delete(e);mn.delete(e)}gn=null}}function yn(t,e){const n=getComputedStyle(t);const o=e==="x"?n.overflowX:n.overflowY;const r=t===document.body||t===document.documentElement;return pn.has(o)||r}function vn(t,e){let n=t?.parentElement;while(n){if(yn(n,e))return n;n=n.parentElement}return null}function xn(t,e,n){const o=e.getBoundingClientRect();const r=n==="x"?Math.max(0,o.left):Math.max(0,o.top);const s=n==="x"?Math.min(window.innerWidth,o.right):Math.min(window.innerHeight,o.bottom);const i=t-r;const c=s-t;if(i<fn){const t=1-i/fn;return{amount:-dn*t*t,edge:"start"}}if(c<fn){const t=1-c/fn;return{amount:dn*t*t,edge:"end"}}return{amount:0,edge:null}}function En(t,e,n,o){if(!t)return;gn=t;const r=vn(t,n);if(!r)return;const s=e-(n==="x"?window.scrollX:window.scrollY);const{amount:i,edge:c}=xn(s,r,n);if(c===null){hn.delete(r);mn.delete(r);return}const u=hn.get(r);const a=r===document.body||r===document.documentElement;if(u!==c){const t=c==="start"&&o<0||c==="end"&&o>0;if(!t)return;hn.set(r,c);const e=n==="x"?r.scrollWidth-(a?window.innerWidth:r.clientWidth):r.scrollHeight-(a?window.innerHeight:r.clientHeight);mn.set(r,e)}if(i>0){const t=mn.get(r);const e=n==="x"?a?window.scrollX:r.scrollLeft:a?window.scrollY:r.scrollTop;if(e>=t)return}n==="x"?a?window.scrollBy({left:i}):r.scrollLeft+=i:a?window.scrollBy({top:i}):r.scrollTop+=i}"use client";function bn(t,e=0){return W(t)?t:oe(e)}function Mn({children:e,style:n={},value:o,as:r="li",onDrag:s,onDragEnd:i,layout:u=true,...a},l){const f=D((()=>Ft[r]));const d=c(rn);const p={x:bn(n.x),y:bn(n.y)};const m=ce([p.x,p.y],(([t,e])=>t||e?1:"unset"));wt(Boolean(d),"Reorder.Item must be a child of Reorder.Group","reorder-item-child");const{axis:h,registerItem:g,updateOrder:w,groupRef:y}=d;return t(f,{drag:h,...a,dragSnapToOrigin:true,style:{...n,x:p.x,y:p.y,zIndex:m},layout:u,onDrag:(t,e)=>{const{velocity:n,point:r}=e;const i=p[h].get();w(o,i,n[h]);En(y.current,r[h],h,n[h]);s&&s(t,e)},onDragEnd:(t,e)=>{wn();i&&i(t,e)},onLayoutMeasure:t=>{g(o,t)},ref:l,ignoreStrict:true,children:e})}const Cn=M(Mn);var Pn=Object.freeze(Object.defineProperty({__proto__:null,Group:un,Item:Cn},Symbol.toStringTag,{value:"Module"}));export{jt as AnimatePresence,Ze as AnimateSharedLayout,Dt as DeprecatedLayoutGroupContext,DragControls,Bt as LayoutGroup,V as LayoutGroupContext,Ht as LazyMotion,$t as MotionConfig,C as MotionConfigContext,j as MotionContext,It as PopChild,Ot as PresenceChild,P as PresenceContext,Pn as Reorder,WillChangeMotionValue,Ee as animationControls,pt as animations,Pt as createScopedAnimate,Xe as disableInstantTransitions,Gt as domAnimation,Jt as domMax,qt as domMin,St as inView,Re as isMotionComponent,Ut as m,Y as makeUseVisualState,Ft as motion,Ct as scroll,Ge as startOptimizedAppearAnimation,Le as transformViewBoxPoint,Ie as unwrapMotionComponent,be as useAnimate,Ce as useAnimation,Me as useAnimationControls,de as useAnimationFrame,Rt as useComposedRefs,Ye as useCycle,Ke as useDeprecatedAnimatedState,on as useDeprecatedInvertedScale,Se as useDomEvent,Ve as useDragControls,ee as useElementScroll,le as useFollowValue,kt as useForceUpdate,je as useInView,Oe as useInstantLayoutTransition,De as useInstantTransition,A as useIsomorphicLayoutEffect,se as useMotionTemplate,oe as useMotionValue,Kt as useMotionValueEvent,ke as usePageInView,at as usePresence,Pe as usePresenceData,ge as useReducedMotion,we as useReducedMotionConfig,Te as useResetProjection,te as useScroll,fe as useSpring,pe as useTime,ce as useTransform,Mt as useUnmountEffect,me as useVelocity,ne as useViewportScroll,he as useWillChange};

