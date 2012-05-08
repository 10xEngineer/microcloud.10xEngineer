// AllocationPool.js
define( function(){
    return sp.Class.create('AllocationPool', {
        constructor: function AllocationPool(klass, maxSize){
            this.klass = klass;
            this.maxSize = maxSize || 100;
            this.pool = [];
        },
        properties: {
            klass: null,
            maxSize: 100,
            pool: null
        },
        methods: {
            borrowItem: function borrowItem(){
                if( this.pool.length > 0 ){
                    return this.pool.pop();
                }else{
                    return new this.klass();
                }
            },
            recycle: function recycle( item ){
                if( this.pool.length < this.maxSize ){
                    this.pool.push( item );
                }
            }
        }
    });
});

/* to use
function main(stage){
    require( ['allocation_pool.js'], function(AllocationPool){
        var pointAllocationPool = new AllocationPool( sp.Point );

        stage.addEventListener( sp.Event.ENTER_FRAME, function(event){
            /*
             * Get five points from the allocation pool rather than calling new sp.Point() five times
             * ...
             * Obviously the number five is just an example.  Get however many your application needs
             */
/*            var pt1 = pointAllocationPool.borrowItem();
            var pt2 = pointAllocationPool.borrowItem();
            var pt3 = pointAllocationPool.borrowItem();
            var pt4 = pointAllocationPool.borrowItem();
            var pt5 = pointAllocationPool.borrowItem();
*/
            /*
             * Use these points in my application somehow...
             * ...
             * fill in your application specific code here...
             */

            /*
             * All finished up!  Now return the points to the allocation pool for re-use
             */
/*            pointAllocationPool.recycle( pt1 );
            pointAllocationPool.recycle( pt2 );
            pointAllocationPool.recycle( pt3 );
            pointAllocationPool.recycle( pt4 );
            pointAllocationPool.recycle( pt5 );
        });
    });
} */